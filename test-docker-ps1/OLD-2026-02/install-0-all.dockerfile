FROM mcr.microsoft.com/windows/servercore:ltsc2019
WORKDIR C:\\install
COPY install-1-pwsh7-copilot-git-claude.ps1 .
COPY install-2-dotnet-gembox-skills.ps1 .
SHELL ["powershell","-NoProfile","-ExecutionPolicy","Bypass","-Command"]
RUN .\install-1-pwsh7-copilot-git-claude.ps1 *>&1 | Tee-Object -FilePath C:\install\log-1-base.txt
RUN .\install-2-dotnet-gembox-skills.ps1 *>&1 | Tee-Object -FilePath C:\install\log-2-gembox.txt
COPY install-3-verify-versions.ps1 .
CMD ["pwsh","-NoExit","-Command","C:\\install\\install-3-verify-versions.ps1"]
