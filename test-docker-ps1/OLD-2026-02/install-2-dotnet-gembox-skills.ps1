# GemBox add-on installer (.NET 10 SDK + GemBox.Bundle + GemBox Skill).
# Run AFTER install-1-pwsh7-copilot-git-claude.ps1.

$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12}catch{}

# --- Resolve LOCALAPPDATA safely (Server Core may miss it) ---
$L=$env:LOCALAPPDATA
if(!$L){$L=Join-Path $env:USERPROFILE "AppData\Local"}

$ROOT=Join-Path $L "cli-agents"
$DOTNET=Join-Path $ROOT "dotnet"
$NUGET=Join-Path $ROOT "nuget"
$PACKAGES=Join-Path $ROOT "packages"
New-Item -ItemType Directory -Force -Path $DOTNET,$NUGET,$PACKAGES | Out-Null

function AddPath($p){
  if(($env:Path -split ';') -notcontains $p){$env:Path+=";$p"}
  $m=[Environment]::GetEnvironmentVariable("Path","Machine")
  if($m -eq $null){$m=""}
  if(($m -split ';') -notcontains $p){
    [Environment]::SetEnvironmentVariable("Path",($m.TrimEnd(';') + ";$p"),"Machine")
  }
}

# --- .NET 10 SDK ---
Write-Host "Installing .NET 10 SDK..."
Invoke-WebRequest -UseBasicParsing https://dot.net/v1/dotnet-install.ps1 -OutFile $env:TEMP\dotnet-install.ps1
& $env:TEMP\dotnet-install.ps1 -Channel 10.0 -InstallDir $DOTNET
AddPath $DOTNET
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

# --- GemBox.Bundle via dotnet NuGet ---
Write-Host "Installing GemBox.Bundle..."
nuget install GemBox.Bundle -OutputDirectory $PACKAGES

# --- GemBox Skill for Claude Code and Copilot CLI ---
Write-Host "Installing GemBox Skill..."
Invoke-WebRequest -UseBasicParsing https://github.com/ZSvedic/GemBox-skills/releases/latest/download/gembox-skill.zip -OutFile $env:TEMP\gembox-skill.zip

# Claude Code: ~/.claude/skills/
$ClaudeSkills="$env:USERPROFILE\.claude\skills"
New-Item -ItemType Directory -Force -Path $ClaudeSkills | Out-Null
Expand-Archive -Force $env:TEMP\gembox-skill.zip $ClaudeSkills
Write-Host "  Claude Code skill: $ClaudeSkills\gembox-skill"

# Copilot CLI: ~/.copilot/skills/
$CopilotSkills="$env:USERPROFILE\.copilot\skills"
New-Item -ItemType Directory -Force -Path $CopilotSkills | Out-Null
Expand-Archive -Force $env:TEMP\gembox-skill.zip $CopilotSkills
Write-Host "  Copilot CLI skill: $CopilotSkills\gembox-skill"

# --- Summary ---
Write-Host "`n=== GemBox Installation Complete ==="
Write-Host "  dotnet:        $(dotnet --version)"
Write-Host "  nuget:         $(nuget help | Select-Object -First 1)"
Write-Host "  GemBox.Bundle: $PACKAGES"
Write-Host "  GemBox Skill:  installed for Claude Code and Copilot CLI"
