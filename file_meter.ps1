# windows wrapper

# check if docker is installed and running
function Test-Docker {
    try {
        $null = docker version 2>&1
        return $true
    }
    catch {
        return $false
    }
}

# run docker commands silently
function Invoke-DockerCommand {
    param (
        [string]$Command
    )
    $output = Invoke-Expression "docker $Command 2>&1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "An error occurred. Please check your Docker installation and try again."
        exit 1
    }
    return $output
}

# validate number of arguments
if ($args.Count -ne 2) {
    Write-Host "Usage: .\file_meter.ps1 <directory_path> <number_of_files>"
    exit 1
}

$DIRECTORY = $args[0]
$NUM_FILES = $args[1]

# directory exists
if (-not (Test-Path -Path $DIRECTORY -PathType Container)) {
    Write-Host "Error: Directory $DIRECTORY does not exist."
    exit 1
}

# Silently check if Docker is installed and running
if (-not (Test-Docker)) {
    Write-Host "Error: Unable to run the application. Please ensure Docker Desktop for Windows is installed and running."
    exit 1
}

# Name of the Docker image
$IMAGE_NAME = "file-meter-app"

# Silently build the Docker image if it doesn't exist
$imageExists = Invoke-DockerCommand "images -q $IMAGE_NAME"
if (-not $imageExists) {
    Write-Host "Preparing application..."
    Invoke-DockerCommand "build -q -t $IMAGE_NAME ."
}

# Run the Docker container and stream its output
Write-Host "Starting file analysis..."
$absolutePath = Resolve-Path $DIRECTORY
docker run --rm -v "${absolutePath}:/scan" $IMAGE_NAME "/scan" $NUM_FILES

Write-Host "Analysis complete."