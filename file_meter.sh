#!/bin/bash

# check if Docker is installed and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed. Please install Docker and try again."
        exit 1
    fi
    if ! docker info &> /dev/null; then
        echo "Error: Docker daemon is not running. Please start Docker and try again."
        exit 1
    fi
}

# main script
main() {
    local directory
    local num_files
    local t_flag=""

    # check if arguments are provided
    if [ $# -ge 2 ] && [ $# -le 3 ]; then
        directory="$1"
        num_files="$2"
        if [ $# -eq 3 ] && [ "$3" = "-t" ]; then
            t_flag="-t"
        fi
    else
        echo "Usage: $0 <directory_path> <number_of_files> [-t]"
        exit 1
    fi

    # validate directory
    if [ ! -d "$directory" ]; then
        echo "Error: Directory $directory does not exist."
        exit 1
    fi

    # check docker
    check_docker

    # run docker container
    echo "Analyzing files in $directory..."
    docker_cmd="docker run -it -v \"$directory:/data\" file-size-analyzer /data $num_files $t_flag"
    echo "Executing: $docker_cmd"
    eval $docker_cmd
}

# Run the main function
main "$@"

echo "Press ENTER to exit..."
read