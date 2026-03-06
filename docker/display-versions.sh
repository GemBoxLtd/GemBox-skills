#!/usr/bin/env bash
set -u

format='%-8s| %-12s| %s\n'
printf "$format" "CHECK" "CMD" "ACTUAL"

# Checks if the cmd (supporting --version) is at least the min version, and prints it.
check() { cmd="$1"; min="$2"
    out=$("$cmd" --version 2>&1 | head -n1)
    ver=$(grep -oE '[0-9]+(\.[0-9]+)+' <<<"$out" | head -n1)
    printf '%s\n%s\n' "$min" "$ver" | sort -V -C 2>/dev/null && r=Pass || r=FAIL
    printf "$format" "$r" "$cmd" "$out"
}

check dotnet 10.0.100
check git 2.43.0
check node 25.7.0
check npm 11.10.0
check codex 0.106.0
check copilot 0.0.420
check claude 2.1.60
check pwsh 7.0.0
check rg 13.0.0