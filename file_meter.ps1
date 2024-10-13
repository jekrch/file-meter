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

# validate number of arguments
if ($args.Count -lt 2 -or $args.Count -gt 3) {
    Write-Host "Usage: .\file_meter.ps1 <directory_path> <number_of_files> [-t]"
    exit 1
}

$DIRECTORY = $args[0]
$NUM_FILES = $args[1]
$T_FLAG = if ($args.Count -eq 3 -and $args[2] -eq "-t") { "-t" } else { $null }

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
$IMAGE_NAME = "file-size-analyzer"

# Run the Docker container and stream its output
Write-Host "Starting file analysis..."
$absolutePath = Resolve-Path $DIRECTORY
$dockerCmd = "docker run -it -v `"${absolutePath}:/data`" $IMAGE_NAME /data $NUM_FILES"
if ($T_FLAG) {
    $dockerCmd += " -t"
}

Write-Host "Executing: $dockerCmd"
Invoke-Expression $dockerCmd

Write-Host "Analysis complete."