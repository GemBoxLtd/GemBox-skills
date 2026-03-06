#!/usr/bin/env bash
set -e

curl -fsSL https://deb.nodesource.com/setup_current.x | bash -

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor -o /usr/share/keyrings/microsoft.gpg

echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/microsoft.gpg] \
  https://packages.microsoft.com/ubuntu/24.04/prod noble main" \
  > /etc/apt/sources.list.d/microsoft-prod.list

apt-get update

apt-get install -y --no-install-recommends \
  nodejs \
  dotnet-sdk-10.0 \
  ripgrep

dotnet tool install -g PowerShell

apt-get clean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /root/.nuget \
    /root/.local/share/NuGet
