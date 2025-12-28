# Build-DockerImages.ps1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageName,

    [switch]$Push   # optional flag, defaults to False
)

if ((podman machine inspect | ConvertFrom-Json).State -ne "Running") {
    podman machine start
}

# Ensure script stops on errors
$ErrorActionPreference = "Stop"

# Step 1: Read the version tag from the VERSION file
if (-Not (Test-Path "./VERSION")) {
    Write-Error "VERSION file not found in current directory."
    exit 1
}
$version = Get-Content -Path "./VERSION" -Raw
$version = $version.Trim()

if ([string]::IsNullOrWhiteSpace($version)) {
    Write-Error "VERSION file is empty or invalid."
    exit 1
}

Write-Host "Using version tag: $version"

# Step 2: Build the main image from Dockerfile
Write-Host "Building main image..."
podman build `
    --file Dockerfile `
    --tag "$($imageName):$version" `
    --tag "$($ImageName):latest" `
    .

if ($Push) {
    Write-Host "Pushing..."
    podman push "$($imageName):$version" 
    podman push "$($imageName):latest"
}

Write-Host "✅ Build complete. Images tagged as:"
