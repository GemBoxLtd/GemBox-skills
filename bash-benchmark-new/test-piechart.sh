#!/bin/bash

N_RUNS="${1:-1}"

PROMPT="Generate C# code, together with project files for opening in VSCode, that uses GemBox.Spreadsheet 2025.12.105 and .NET 10 (both installed on this machine). 
That C# code should:
- Create a sheet 'Breakdown' with columns 'Continents' and 'Area (km2)'.
- Bold header, autofit columns, use thousands separators.
- Create a pie chart 'Landmass breakdown' to the right of the table.
- Set chart labels to include continent name, area value, and percentage.
- In a row below the table, in A column, list all skills used in this task, or 'No skills' if none were used. 
- Save to file 'Earth–HHhMMm.xlsx' (24-hour time, dynamically computed).
After generating the code:
- Build and execute the code, fix it if there are issues.
- Verify the generated XLSX file contains the chart by unzipping and inspecting (e.g. with unzip -l file.xlsx | grep -i 'xl/charts')."

./benchmark-agents.sh "$PROMPT" "$N_RUNS" "PieChart" 
