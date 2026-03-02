#!/usr/bin/env bash

N_RUNS="${1:-1}"
AGENTS="${2:-}"

PROMPT="Generate C# code, together with project files for opening in VSCode, that uses GemBox.Pdf 2026.2.100 and .NET 10.
The code should:
- Load the /test-files/gba.pdf file. 
- 10 points below the heading “GemBox.Spreadsheet”, insert the following text with formatting: <b><u>GemBox.Spreadsheet</u></b> is a versatile <span style="color:red">.NET library</span>
- 50 points to the left of the company logo that is in the top-right corner, insert the GemBox.Spreadsheet logo (you should download it from https://www.gemboxsoftware.com/img/products/gbs-icon-blue.png). The inserted image needs to have the same height as the company logo. The image should retain its aspect ratio, so the width should be correctly calculated.
- Add another page with the same size as the previous page. In the middle of the new page insert a circle with 50px radius and with blue background.
- Save the file to "Result.pdf"
After generating the code:
- Build and execute the code, fix it if there are issues."

./benchmark-agents.sh "$PROMPT" "$N_RUNS" "Pdf" "$AGENTS"
