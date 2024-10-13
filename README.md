# File Meter

A Docker-based tool to find the largest files in a specified directory.

## Requirements

- Docker

## Setup

1. Clone this repository
2. Ensure Docker is running

## Usage

### Windows

Run `file_meter.bat`:
```
file_meter.bat C:\path\to\directory 10
```
Or double-click to run interactively.

### Linux

Make the script executable:
```
chmod +x file_meter.sh
```

Run the script:
```
./file_meter.sh /path/to/directory 10
```
Or run without arguments for interactive mode.

## Contents

- `Dockerfile`: Defines the Docker image
- `entrypoint.sh`: Docker container entry point
- `file_size_analyzer.sh`: Main file analysis script
- `file_meter.bat`: Windows wrapper
- `file_meter.ps1`: PowerShell script for Windows
- `file_meter.sh`: Linux wrapper

## Notes

This is a personal learning project to explore Docker and file system operations.