$sourceFiles = Get-ChildItem -Path . -Recurse -Include *.lua, *.toc, *.tga, *.png -File
$destinationFolder = "./build"

$tocFile = Get-ChildItem -Path . -Filter *.toc | Select-Object -First 1
if (-not $tocFile) {
    Write-Error "No .toc file found in the current directory. Task will be terminated."
    return
}
Write-Host "Found TOC file: $($tocFile.Name)"

Write-Host "Reading metadata from '$($tocFile.Name)'..."
$addonName = ""
$version = ""
try {
    $tocContent = Get-Content $tocFile.FullName

    $titleLine = $tocContent | Where-Object { $_ -match "^\s*##\s*Title:" }
    if ($titleLine) {
        $addonName = ($titleLine -split ":", 2)[1].Trim()
        Write-Host "Addon name found: $addonName"
    } else {
        Write-Error "No '## Title:' found in .toc file. Cannot determine addon name. Task will be terminated."
        return
    }

    $versionLine = $tocContent | Where-Object { $_ -match "^\s*##\s*Version:" }
    if ($versionLine) {
        $version = ($versionLine -split ":", 2)[1].Trim()
        Write-Host "Version found: $version"
    } else {
        $version = "0.0.0-dev"
        Write-Warning "No '## Version:' found in .toc file. Using '$version' as fallback."
    }
} catch {
    Write-Error "Error while reading '$($tocFile.Name)'. Task will be terminated."
    return
}

$zipFile = "./build/$($addonName)-$($version).zip"
Write-Host "ZIP archive name: '$zipFile'"

if (Test-Path $destinationFolder) {
    Remove-Item -Recurse -Force $destinationFolder
}
New-Item -ItemType Directory -Force -Path $destinationFolder | Out-Null

$basePath = (Get-Location).Path
$targetRoot = Join-Path $destinationFolder $addonName

Write-Host "Copying files and preserving directory structure..."
foreach ($item in $sourceFiles) {
    $relativePath = $item.FullName.Substring($basePath.Length).TrimStart("\")

    $destinationPath = Join-Path $targetRoot $relativePath

    $destinationDir = Split-Path -Path $destinationPath -Parent

    if (-not (Test-Path $destinationDir)) {
        New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
    }

    Copy-Item -Path $item.FullName -Destination $destinationPath
    Write-Host "Copied '$relativePath'"
}

if (Test-Path $zipFile) {
    Remove-Item $zipFile
}

Compress-Archive -Path "$destinationFolder/$addonName" -DestinationPath $zipFile

Write-Host "Delete temporary data..."
Remove-Item -Recurse -Force "$destinationFolder/$addonName"

Write-Host "ZIP archive created: $zipFile"