#!/bin/bash

TIMESTAMP="D$(date +%y%m%d)-T$(date +%H%M)"

PROMPT="Generate one Python code file, named 'Claude-${TIMESTAMP}.py', that:
- Has a generic factorial(n) method that calculates N up to 50!.
- Has simple tests in main for 0!, 1!, 5!, 25! and 50!.
- Accepts N from command line, if none is provided, then just displays usage and results of tests.
After generating the code:
- Verify the code runs and works from CLI."

JQ_FILTER='
.. | objects |
if has("text") then
  .text
elif .type=="tool_use" then
  if .name=="Bash" then
    "[TOOL:Bash] " + (.input.command // "")
  elif .name=="Write" then
    "[WRITE] " + (.input.file_path // "")
  else
    "[TOOL] " + .name
  end
else
  empty
end
'

claude -p --verbose -debug --output-format json --permission-mode bypassPermissions "$PROMPT" \
  2>&1 | jq -r "$JQ_FILTER" | tee "Claude-${TIMESTAMP}.log"