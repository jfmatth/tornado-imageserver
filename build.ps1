# Build-DockerImages.ps1

[CmdletBinding()]
param(
    [string]$ImageName,
    [switch]$Push   
)

# Ensure script stops on errors
$ErrorActionPreference = "Stop"

$imagefile = "IMAGE"

if (Test-Path $imagefile) {
    # REPO EXISTS, use it's content for the variable
    $ImageName = Get-Content -Raw -Path $imagefile
} elseif (-not $ImageName) {
    Write-Error "No Repository and File REPO doesn't exist"
    exit 1
}

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

if ((podman machine inspect | ConvertFrom-Json).State -ne "Running") {
    podman machine start
}

Write-Host "Using version tag: $version"

# Step 2: Build the main image from Dockerfile
Write-Host "Building main image $ImageName"
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
