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

# build docker image if it doesn't exist
build_image() {
    if [[ "$(docker images -q file-meter-app 2> /dev/null)" == "" ]]; then
        echo "Preparing application..."
        docker build -q -t file-meter-app . > /dev/null
    fi
}

# main script
main() {
    local directory
    local num_files

    # check if arguments are provided
    if [ $# -eq 2 ]; then
        directory="$1"
        num_files="$2"
    else
        # prompt for input if arguments are not provided
        read -p "Enter the directory path to scan: " directory
        read -p "Enter the number of largest files to find: " num_files
    fi

    # validate directory
    if [ ! -d "$directory" ]; then
        echo "Error: Directory $directory does not exist."
        exit 1
    fi

    # check docker and build image
    check_docker
    build_image

    # run docker container
    echo "Analyzing files in $directory..."
    docker run --rm -v "$directory:/scan" file-meter-app "/scan" "$num_files"
}

# Run the main function
main "$@"

echo "Press ENTER to exit..."
read