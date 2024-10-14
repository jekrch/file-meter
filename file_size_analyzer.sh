#!/bin/bash

# handle script interruption
cleanup() {
    echo -e "\n\nScan interrupted. Showing results so far:"
    print_results
    rm -f "$temp_results" "$type_results" "$pipe"
    exit 1
}

# convert file size to human-readable format
human_readable() {
    awk '{ split( "B KB MB GB TB PB EB ZB YB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } printf "%.1f %s", $1, v[s] }' <<< "$1"
}

# print final results
print_results() {
    if [ "$show_types" = true ]; then
        echo "Analysis complete. Top $NUM_FILES file types by total size:"
        if [ ! -s "$type_results" ]; then
            echo "No results found."
        else
            printf "%-20s | %-10s | %-15s | %s\n" "Total Size" "Count" "Avg Size" "File Type"
            printf "%s\n" "--------------------+------------+-----------------+------------------"
            sort -t'|' -k2 -rn "$type_results" | head -n "$NUM_FILES" | while IFS='|' read -r avg_size total_size count ext; do
                human_total=$(human_readable "$total_size")
                human_avg=$(human_readable "$avg_size")
                printf "%-20s | %-10s | %-15s | %s\n" "$human_total" "$count" "$human_avg" "$ext"
            done
        fi
    else
        echo "Analysis complete. Largest $NUM_FILES files:"
        if [ ! -s "$temp_results" ]; then
            echo "No results found."
        else
            printf "%-15s | %s\n" "Size" "File"
            printf "%s\n" "----------------+$(printf -- '-%.0s' {1..50})"
            while IFS='|' read -r size file; do
                printf "%-15s | %s\n" "$size" "$file"
            done < "$temp_results"
        fi
    fi
}

# trap for script interruption
trap cleanup SIGINT

# check for correct number of arguments
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <directory_path> <number_of_files_or_types> [-t]"
    exit 1
fi

DIRECTORY=$1
NUM_FILES=$2
show_types=false

if [ "$#" -eq 3 ] && [ "$3" = "-t" ]; then
    show_types=true
fi

# does directory exist?
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory $DIRECTORY does not exist."
    exit 1
fi

echo "Analyzing files..."
echo "Press Ctrl+C to stop the scan and see current results."

# count total files
echo "Counting files..."
total_files=$(find "$DIRECTORY" -type f -printf . | wc -c)
echo "Total files to process: $total_files"

# Function to update progress bar
update_progress() {
    local current=$1
    local total=$2
    local progress=$((current * 100 / total))
    local completed=$((progress / 2))
    local remaining=$((50 - completed))
    printf "\rProgress: [%-${completed}s%-${remaining}s] %d%%" "$(printf '#%.0s' $(seq 1 $completed))" "$(printf '.%.0s' $(seq 1 $remaining))" "$progress"
}

echo "Scanning files..."

# use a named pipe for progress tracking
pipe=$(mktemp -u)
mkfifo "$pipe"

# create temp files to store results
temp_results=$(mktemp)
type_results=$(mktemp)

# background process to read from pipe and update progress
{
    processed=0
    while read -r _; do
        ((processed++))
        if ((processed % 100 == 0)) || ((processed == total_files)); then
            update_progress "$processed" "$total_files"
        fi
    done < "$pipe"
    echo  # New line after progress bar
} &

# main processing loop
if [ "$show_types" = true ]; then
    find "$DIRECTORY" -type f -printf "%s %p\n" | tee "$pipe" | 
    awk '
    function get_ext(file) {
        ext = tolower(file)
        sub(/.*\./, "", ext)
        if (ext == "" || index(file, ".") == 0) 
            return "no_extension"
        return ext
    }
    {
        size = $1
        file = $0
        sub(/^[^ ]+ /, "", file)
        ext = get_ext(file)
        count[ext]++
        sum[ext] += size
        if (size > max[ext]) max[ext] = size
    } 
    END {
        for (ext in count) {
            avg = sum[ext] / count[ext]
            printf "%.0f|%.0f|%d|%s\n", avg, sum[ext], count[ext], ext
        }
    }' > "$type_results"
else
    find "$DIRECTORY" -type f -printf "%s %p\n" | tee "$pipe" | sort -rn | head -n "$NUM_FILES" | 
    while IFS= read -r line; do
        size=${line%% *}
        file=${line#* }
        human_size=$(human_readable "$size")
        printf "%s|%s\n" "$human_size" "${file#$DIRECTORY/}" >> "$temp_results"
    done
fi

# close and remove the named pipe
exec 3>&-
rm "$pipe"

wait  # wait for the background progress bar process to finish

# print final results
print_results

# clean up
rm -f "$temp_results" "$type_results"