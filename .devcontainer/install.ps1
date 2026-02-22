# Install or update devcontainer-template into the current project
# Usage:
#   First time:  irm https://raw.githubusercontent.com/aspinall/devcontainer-template/main/.devcontainer/install.ps1 | iex
#   Update:      & .devcontainer/install.ps1

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Repo = 'aspinall/devcontainer-template'
$Branch = 'main'
$ZipUrl = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "devcontainer-template-$([System.Guid]::NewGuid().ToString('N'))"

try {
    # --- Download ---
    Write-Host "Downloading latest template from $Repo..."
    New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null

    $ZipPath = Join-Path $TmpDir 'template.zip'
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing

    Expand-Archive -Path $ZipPath -DestinationPath $TmpDir -Force

    $SrcDir = Join-Path $TmpDir "devcontainer-template-$Branch"

    if (-not (Test-Path $SrcDir)) {
        Write-Error 'Error: unexpected archive structure.'
        exit 1
    }

    # --- Install files ---
    # Template-owned files: always overwritten on update
    $TemplateFiles = @(
        '.devcontainer/docker-compose.yml'
        '.devcontainer/setup.sh'
        '.devcontainer/install.sh'
        '.devcontainer/install.ps1'
    )

    # User-owned files: only created if missing, never overwritten
    $UserFiles = @(
        '.devcontainer/devcontainer.json'
    )

    if (-not (Test-Path '.devcontainer')) {
        New-Item -ItemType Directory -Path '.devcontainer' -Force | Out-Null
    }

    foreach ($File in $TemplateFiles) {
        $SrcFile = Join-Path $SrcDir $File
        if (-not (Test-Path $File)) {
            $Status = 'Installing'
        } elseif ((Get-FileHash $File -Algorithm SHA256).Hash -eq (Get-FileHash $SrcFile -Algorithm SHA256).Hash) {
            $Status = 'Unchanged'
        } else {
            $Status = 'Updating'
        }
        Write-Host ('  {0,-12} {1}' -f $Status, $File)
        if ($Status -ne 'Unchanged') {
            Copy-Item -Path $SrcFile -Destination $File -Force
        }
    }

    foreach ($File in $UserFiles) {
        $SrcFile = Join-Path $SrcDir $File
        if (-not (Test-Path $File)) {
            $Status = 'Installing'
            Write-Host ('  {0,-12} {1}' -f $Status, $File)
            Copy-Item -Path $SrcFile -Destination $File -Force
        } else {
            Write-Host ('  {0,-12} {1} (user-managed)' -f 'Skipping', $File)
        }
    }

    Write-Host ''
    Write-Host "Done. Open this folder in VS Code and use 'Reopen in Container'."
}
finally {
    if (Test-Path $TmpDir) {
        Remove-Item -Recurse -Force $TmpDir
    }
}
