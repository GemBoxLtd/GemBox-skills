FROM mcr.microsoft.com/windows/servercore:ltsc2019
WORKDIR C:\\install
COPY native-install-copilot-claude.ps1 .
SHELL ["powershell","-NoProfile","-ExecutionPolicy","Bypass","-Command"]
RUN .\native-install-copilot-claude.ps1 *>&1 | Tee-Object -FilePath C:\install\build-log-latest.txt
CMD ["powershell","-NoLogo"]