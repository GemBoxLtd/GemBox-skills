Set-PSDebug -Trace 1
pwsh -v
copilot -v
claude -v
git -v
bash --version
dotnet --version
nuget help | Select-Object -First 1
Get-ChildItem $env:USERPROFILE\.nuget\packages\gembox*
Get-ChildItem $env:USERPROFILE\.claude\skills
Get-ChildItem $env:USERPROFILE\.copilot\skills
Set-PSDebug -Trace 0
Write-Host "If not already logged in, run 'copilot' or 'claude' and then '/login'."