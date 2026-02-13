# Minimal native installer for PowerShell 7 + Copilot CLI + Git (with git-bash) + Claude Code.
# Works on Win10/Win11 x64 and Windows Server Core containers.
# Installs user-local to %LOCALAPPDATA%\cli-agents.
# Persists PATH to Machine scope.
# Uses TLS 1.2 + GitHub “latest” APIs to avoid hard-coded versions.

$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12}catch{}

# --- Resolve LOCALAPPDATA safely (Server Core may miss it) ---
$L=$env:LOCALAPPDATA
if(!$L){$L=Join-Path $env:USERPROFILE "AppData\Local"}

$ROOT=Join-Path $L "cli-agents"
$COP=Join-Path $ROOT "copilot"
$GIT=Join-Path $ROOT "git"
New-Item -ItemType Directory -Force -Path $COP,$GIT | Out-Null

function AddPath($p){
  if(($env:Path -split ';') -notcontains $p){$env:Path+=";$p"}
  $m=[Environment]::GetEnvironmentVariable("Path","Machine")
  if($m -eq $null){$m=""}
  if(($m -split ';') -notcontains $p){
    [Environment]::SetEnvironmentVariable("Path",($m.TrimEnd(';') + ";$p"),"Machine")
  }
}

# --- Copilot doesn't know PowerShell 5.1, so install pwsh 7.4.6 ---
# NOTE: Latest version that works is 7.4.6, as pwsh 7.4.7+ are incompatible with docker:
# https://github.com/PowerShell/PowerShell/issues/25541
Invoke-WebRequest https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/PowerShell-7.4.6-win-x64.msi -OutFile $env:TEMP\pwsh7.msi
msiexec /i $env:TEMP\pwsh7.msi /qn /norestart
AddPath "C:\Program Files\PowerShell\7"

# --- Copilot CLI (download zip, extract, add PATH) ---
Invoke-WebRequest -UseBasicParsing https://github.com/github/copilot-cli/releases/latest/download/copilot-win32-x64.zip -OutFile $env:TEMP\cop.zip
Expand-Archive -Force $env:TEMP\cop.zip $COP
AddPath $COP
copilot --version

# --- Portable Git for bash.exe (required by Claude) ---
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

# --- Claude Code installer + PATH ---
Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
$CLA="$env:USERPROFILE\.local\bin"
AddPath $CLA
claude --version

Write-Host "`nNext: run 'copilot' then /login, and 'claude' then /login"