#!/bin/bash

TIMESTAMP="D$(date +%y%m%d)-T$(date +%H%M)"

PROMPT="Generate one Python code file, named 'Copilot-${TIMESTAMP}.py', that:
- Has a generic factorial(n) method that calculates N up to 50!.
- Has simple tests in main for 0!, 1!, 5!, 25! and 50!.
- Accepts N from command line, if none is provided, then just displays usage and results of tests.
After generating the code:
- Verify the code runs and works from CLI."

copilot --allow-all-tools -p "$PROMPT" 2>&1 | tee "Copilot-${TIMESTAMP}.log"