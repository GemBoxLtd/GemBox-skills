FROM mcr.microsoft.com/windows/servercore:ltsc2019
WORKDIR C:\\install
SHELL ["powershell","-NoProfile","-ExecutionPolicy","Bypass","-Command"]

# Set up environment and helper function
RUN $ErrorActionPreference='Stop'; \
    $ProgressPreference='SilentlyContinue'; \
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; \
    $L=$env:LOCALAPPDATA; if(!$L){$L=Join-Path $env:USERPROFILE 'AppData\Local'}; \
    $ROOT=Join-Path $L 'cli-agents'; \
    New-Item -ItemType Directory -Force -Path $ROOT | Out-Null

# Install Copilot CLI
RUN $ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; \
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; \
    $L=$env:LOCALAPPDATA; if(!$L){$L=Join-Path $env:USERPROFILE 'AppData\Local'}; \
    $ROOT=Join-Path $L 'cli-agents'; $COP=Join-Path $ROOT 'copilot'; \
    New-Item -ItemType Directory -Force -Path $COP | Out-Null; \
    Invoke-WebRequest -UseBasicParsing https://github.com/github/copilot-cli/releases/latest/download/copilot-win32-x64.zip -OutFile $env:TEMP\cop.zip; \
    Expand-Archive -Force $env:TEMP\cop.zip $COP; \
    Remove-Item $env:TEMP\cop.zip -Force; \
    $m=[Environment]::GetEnvironmentVariable('Path','Machine'); \
    [Environment]::SetEnvironmentVariable('Path',($m.TrimEnd(';')+';'+$COP),'Machine'); \
    Write-Host "Copilot CLI installed"

# Install Portable Git
RUN $ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; \
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; \
    $L=$env:LOCALAPPDATA; if(!$L){$L=Join-Path $env:USERPROFILE 'AppData\Local'}; \
    $ROOT=Join-Path $L 'cli-agents'; $GIT=Join-Path $ROOT 'git'; \
    New-Item -ItemType Directory -Force -Path $GIT | Out-Null; \
    $rel=Invoke-RestMethod https://api.github.com/repos/git-for-windows/git/releases/latest -Headers @{'User-Agent'='ps'}; \
    $url=($rel.assets | Where-Object {$_.name -match 'PortableGit-.*-64-bit\.7z\.exe'} | Select-Object -First 1).browser_download_url; \
    Write-Host "Downloading from: $url"; \
    Invoke-WebRequest -UseBasicParsing $url -OutFile $env:TEMP\git.exe; \
    Write-Host "Extracting to: $GIT"; \
    $p = Start-Process -FilePath $env:TEMP\git.exe -ArgumentList ('-o'+$GIT),'-y' -Wait -PassThru; \
    Write-Host "Exit code: $($p.ExitCode)"; \
    if(!(Test-Path (Join-Path $GIT 'bin\git.exe'))){throw 'Git extraction failed'}; \
    Remove-Item $env:TEMP\git.exe -Force; \
    $m=[Environment]::GetEnvironmentVariable('Path','Machine'); \
    [Environment]::SetEnvironmentVariable('Path',($m.TrimEnd(';')+';'+$GIT+'\bin;'+$GIT+'\usr\bin'),'Machine'); \
    Write-Host "Portable Git installed to $GIT"

# Install .NET 10 SDK
RUN $ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; \
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; \
    $L=$env:LOCALAPPDATA; if(!$L){$L=Join-Path $env:USERPROFILE 'AppData\Local'}; \
    $ROOT=Join-Path $L 'cli-agents'; $DOTNET=Join-Path $ROOT 'dotnet'; \
    Invoke-WebRequest -UseBasicParsing https://dot.net/v1/dotnet-install.ps1 -OutFile $env:TEMP\dotnet-install.ps1; \
    & $env:TEMP\dotnet-install.ps1 -Channel 10.0 -InstallDir $DOTNET; \
    Remove-Item $env:TEMP\dotnet-install.ps1 -Force; \
    $m=[Environment]::GetEnvironmentVariable('Path','Machine'); \
    [Environment]::SetEnvironmentVariable('Path',($m.TrimEnd(';')+';'+$DOTNET),'Machine'); \
    Write-Host ".NET 10 SDK installed"

# Install NuGet CLI
RUN $ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; \
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; \
    $L=$env:LOCALAPPDATA; if(!$L){$L=Join-Path $env:USERPROFILE 'AppData\Local'}; \
    $ROOT=Join-Path $L 'cli-agents'; $NUGET=Join-Path $ROOT 'nuget'; \
    New-Item -ItemType Directory -Force -Path $NUGET | Out-Null; \
    Invoke-WebRequest -UseBasicParsing https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile "$NUGET\nuget.exe"; \
    $m=[Environment]::GetEnvironmentVariable('Path','Machine'); \
    [Environment]::SetEnvironmentVariable('Path',($m.TrimEnd(';')+';'+$NUGET),'Machine'); \
    Write-Host "NuGet CLI installed"

# Install GemBox.Bundle
RUN $ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; \
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; \
    $L=$env:LOCALAPPDATA; if(!$L){$L=Join-Path $env:USERPROFILE 'AppData\Local'}; \
    $ROOT=Join-Path $L 'cli-agents'; \
    $NUGET=Join-Path $ROOT 'nuget'; $PACKAGES=Join-Path $ROOT 'packages'; \
    New-Item -ItemType Directory -Force -Path $PACKAGES | Out-Null; \
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine'); \
    & "$NUGET\nuget.exe" install GemBox.Bundle -OutputDirectory $PACKAGES; \
    Write-Host "GemBox.Bundle installed"

# Install Claude Code (NOTE: May fail in containers lacking AVX CPU support or sufficient memory)
# The Bun-based installer requires AVX CPU instructions and ~1GB+ memory
RUN $ErrorActionPreference='Continue'; $ProgressPreference='SilentlyContinue'; \
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; \
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine'); \
    try { irm https://claude.ai/install.ps1 | iex } catch { Write-Host "Claude Code install failed: $_" }; \
    $CLA=(Join-Path $env:USERPROFILE '.local\bin'); \
    if(Test-Path (Join-Path $CLA 'claude.exe')){ \
        $m=[Environment]::GetEnvironmentVariable('Path','Machine'); \
        [Environment]::SetEnvironmentVariable('Path',($m.TrimEnd(';')+';'+$CLA),'Machine'); \
        Write-Host "Claude Code installed successfully" \
    } else { \
        Write-Host "WARNING: Claude Code installation failed - container may lack AVX CPU support or memory" \
    }

# Install GemBox Skill for Claude Code
RUN $ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; \
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; \
    $SKILLS=(Join-Path $env:USERPROFILE '.claude\skills'); \
    New-Item -ItemType Directory -Force -Path $SKILLS | Out-Null; \
    Invoke-WebRequest -UseBasicParsing https://github.com/ZSvedic/GemBox-skills/releases/latest/download/gembox-skill.zip -OutFile $env:TEMP\gembox-skill.zip; \
    Expand-Archive -Force $env:TEMP\gembox-skill.zip $SKILLS; \
    Remove-Item $env:TEMP\gembox-skill.zip -Force; \
    Write-Host ('GemBox Skill installed to ' + $SKILLS + '\gembox-skill')

# Verify installations
RUN $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine'); \
    Write-Host '=== Verification ==='; \
    Write-Host "dotnet: $(dotnet --version)"; \
    Write-Host "nuget: $((nuget help | Select-Object -First 1))"; \
    Write-Host "git: $(git --version)"; \
    Write-Host "copilot: $(copilot --version)"; \
    $claudeExe = Join-Path $env:USERPROFILE '.local\bin\claude.exe'; \
    if(Test-Path $claudeExe){ Write-Host "claude: $(& $claudeExe --version)" } else { Write-Host 'claude: NOT INSTALLED - see container limitations' }

CMD ["powershell","-NoLogo"]
