#!/bin/bash

# handle script interruption
cleanup() {
    echo -e "\n\nScan interrupted. Showing results so far:"
    print_results
    rm -f "$temp_results" "$pipe"
    exit 1
}

# print final results
print_results() {
    echo "Analysis complete. Largest files:"
    if [ ! -s "$temp_results" ]; then
        echo "No results found."
    else
        printf "%-15s | %s\n" "Size" "File"
        printf "%s\n" "----------------+$(printf -- '-%.0s' {1..50})"
        while IFS='|' read -r size file; do
            printf "%-15s | %s\n" "$size" "$file"
        done < "$temp_results"
    fi
}

# trap for script interruption
trap cleanup SIGINT

# check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory_path> <number_of_files>"
    exit 1
fi

DIRECTORY=$1
NUM_FILES=$2

# does directory exist?
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory $DIRECTORY does not exist."
    exit 1
fi

echo "Finding the $NUM_FILES largest files..."
echo "Press Ctrl+C to stop the scan and see current results."

# cound total files
echo "Counting files..."
total_files=$(find "$DIRECTORY" -type f -printf . | wc -c)
echo "Total files to process: $total_files"

# convert file size to human-readable format
human_readable() {
    numfmt --to=iec-i --suffix=B --format="%.1f" "$1"
}

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

# create temp file to store results
temp_results=$(mktemp)

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
find "$DIRECTORY" -type f -printf "%s %p\n" | tee "$pipe" | sort -rn | head -n "$NUM_FILES" | 
while IFS= read -r line; do
    size=${line%% *}
    file=${line#* }
    human_size=$(human_readable "$size")
    printf "%s|%s\n" "$human_size" "${file#$DIRECTORY/}" >> "$temp_results"
done

# close and remove the named pipe
exec 3>&-
rm "$pipe"

wait  # wait for the background progress bar process to finish

echo -e "\nProcessing..."

# print final results
print_results

# clean up
rm -f "$temp_results"