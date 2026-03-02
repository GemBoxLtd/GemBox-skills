#!/usr/bin/env bash

N_RUNS="${1:-1}"
AGENTS="${2:-}"

PROMPT="Generate C# code, together with project files for opening in VSCode, that uses GemBox.Presentation 2026.2.100 and .NET 10. 
That C# code should:
- Create a new presentation.
- The first slide should be filled with the HTML content present in /test-files/sample-content.html.
- On the second slide, create a table and fill it with the data present in /test-files/yearly-revenue.md.
- On the third slide, create a line chart. The x axis will show the year and the y axis will show the revenue.
- On the last slide, include the GemBox logo in the center of the slide. You can fetch it from https://www.gemboxsoftware.com/img/company/logo.svg.
- Right above the GemBox logo, list in a short sentence all skills used in this task, or 'No skills' if none were used. e.g.: 'Skills used to compose this presentation: example-skill-a and example-skill-b'.
- After saving the .PPTX file, the program should read the generated file and confirm that all elements are there correctly (four slides with the expected content in each).
- Print to the console whether the final validation succeeded or failed. In case of failures, print what is missing or wrong.
After generating the code:
- Build and execute the code, fix it if there are issues.

./benchmark-agents.sh "$PROMPT" "$N_RUNS" "Email" "$AGENTS"
