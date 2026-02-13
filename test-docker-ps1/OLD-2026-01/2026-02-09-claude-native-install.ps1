# Minimal native installer for Copilot CLI + Portable Git (bash) + Claude Code
# + .NET 10 SDK + NuGet CLI + GemBox.Bundle + GemBox Skill
# Works on Win10/Win11 x64 and Windows Server Core containers
# Installs user-local to %LOCALAPPDATA%\cli-agents (no C:\ writes)
# Persists PATH to Machine scope and refreshes current shell
# Uses TLS 1.2 + GitHub "latest" APIs to avoid hard-coded versions

$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12}catch{}

# --- Resolve LOCALAPPDATA safely (Server Core may miss it) ---
$L=$env:LOCALAPPDATA
if(!$L){$L=Join-Path $env:USERPROFILE "AppData\Local"}

$ROOT=Join-Path $L "cli-agents"
$COP=Join-Path $ROOT "copilot"
$GIT=Join-Path $ROOT "git"
$DOTNET=Join-Path $ROOT "dotnet"
$NUGET=Join-Path $ROOT "nuget"
$PACKAGES=Join-Path $ROOT "packages"
New-Item -ItemType Directory -Force -Path $COP,$GIT,$DOTNET,$NUGET,$PACKAGES | Out-Null

function AddPath($p){
  if(($env:Path -split ';') -notcontains $p){$env:Path+=";$p"}
  $m=[Environment]::GetEnvironmentVariable("Path","Machine")
  if($m -eq $null){$m=""}
  if(($m -split ';') -notcontains $p){
    [Environment]::SetEnvironmentVariable("Path",($m.TrimEnd(';') + ";$p"),"Machine")
  }
}

# --- Copilot CLI (download zip, extract, add PATH) ---
Write-Host "Installing Copilot CLI..."
Invoke-WebRequest -UseBasicParsing https://github.com/github/copilot-cli/releases/latest/download/copilot-win32-x64.zip -OutFile $env:TEMP\cop.zip
Expand-Archive -Force $env:TEMP\cop.zip $COP
AddPath $COP
copilot --version

# --- Portable Git for bash.exe (required by Claude) ---
Write-Host "Installing Portable Git..."
$rel=Invoke-RestMethod https://api.github.com/repos/git-for-windows/git/releases/latest -Headers @{"User-Agent"="ps"}
$url=($rel.assets | Where-Object {$_.name -match 'PortableGit-.*-64-bit\.7z\.exe'} | Select-Object -First 1).browser_download_url
Invoke-WebRequest -UseBasicParsing $url -OutFile $env:TEMP\git.exe
& $env:TEMP\git.exe "-o$GIT" "-y" | Out-Null
AddPath "$GIT\bin"
AddPath "$GIT\usr\bin"
# Refresh PATH from registry so bash is visible immediately
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path","User")
bash --version

# --- .NET 10 SDK ---
Write-Host "Installing .NET 10 SDK..."
Invoke-WebRequest -UseBasicParsing https://dot.net/v1/dotnet-install.ps1 -OutFile $env:TEMP\dotnet-install.ps1
& $env:TEMP\dotnet-install.ps1 -Channel 10.0 -InstallDir $DOTNET
AddPath $DOTNET
# Refresh PATH so dotnet is visible
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path","User")
dotnet --version

# --- NuGet CLI ---
Write-Host "Installing NuGet CLI..."
Invoke-WebRequest -UseBasicParsing https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile "$NUGET\nuget.exe"
AddPath $NUGET
# Refresh PATH so nuget is visible
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path","User")
nuget help | Select-Object -First 1

# --- GemBox.Bundle via NuGet ---
Write-Host "Installing GemBox.Bundle..."
nuget install GemBox.Bundle -OutputDirectory $PACKAGES

# --- Claude Code installer + PATH ---
# NOTE: The Bun-based installer may fail in containers lacking AVX CPU support or sufficient memory
Write-Host "Installing Claude Code..."
$ClaudeInstallFailed = $false
try {
    irm https://claude.ai/install.ps1 | iex
} catch {
    Write-Host "WARNING: Claude Code installation threw an error: $_"
    $ClaudeInstallFailed = $true
}
$CLA="$env:USERPROFILE\.local\bin"
if(Test-Path "$CLA\claude.exe") {
    AddPath $CLA
    claude --version
} else {
    Write-Host "WARNING: Claude Code was not installed - container may lack AVX CPU support or memory"
    $ClaudeInstallFailed = $true
}

# --- GemBox Skill for Claude Code ---
Write-Host "Installing GemBox Skill for Claude Code..."
$SKILLS="$env:USERPROFILE\.claude\skills"
$GEMBOX_SKILL="$SKILLS\gembox-skill"
New-Item -ItemType Directory -Force -Path $SKILLS | Out-Null
Invoke-WebRequest -UseBasicParsing https://github.com/ZSvedic/GemBox-skills/releases/latest/download/gembox-skill.zip -OutFile $env:TEMP\gembox-skill.zip
Expand-Archive -Force $env:TEMP\gembox-skill.zip $SKILLS
Write-Host "GemBox Skill installed to: $GEMBOX_SKILL"

Write-Host "`n=== Installation Complete ==="
Write-Host "Installed versions:"
Write-Host "  dotnet:  $(dotnet --version)"
Write-Host "  nuget:   $(nuget help | Select-Object -First 1)"
Write-Host "  git:     $(git --version)"
Write-Host "  copilot: $(copilot --version)"
if(Test-Path "$CLA\claude.exe") {
    Write-Host "  claude:  $(claude --version)"
} else {
    Write-Host "  claude:  NOT INSTALLED (see warning above)"
}
Write-Host "`nGemBox.Bundle packages: $PACKAGES"
Write-Host "GemBox Skill: $GEMBOX_SKILL"
Write-Host "`nNext steps:"
Write-Host "  - Run 'copilot' then /login"
if(Test-Path "$CLA\claude.exe") {
    Write-Host "  - Run 'claude' then /login"
    Write-Host "  - Verify skill: claude /skills list"
} else {
    Write-Host "  - Claude Code must be installed manually on a system with AVX CPU support"
}
