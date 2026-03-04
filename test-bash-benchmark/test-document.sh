#!/usr/bin/env bash

N_RUNS="${1:-1}"
AGENTS="${2:-}"

PROMPT="Generate C# code, together with project files for opening in VSCode, that uses GemBox.Document 2026.2.100 and .NET 10.
- Your task is to generate documents with information about GemBox components. For every GemBox component you need to generate exactly one PDF file with the information about the component.
- Use the data in /test-files/gembox-components.md for information about components
- You will use the /test-files/mail-merge-template.docx file as the template
- For each row in the /test-files/gembox-components.md, create one PDF file that has the appropriate cells filled with data.
- Don't fill the cells with data directly, instead use the mail merge feature for this
    - First add appropriate merge fields to empty cells of the template. You can analyze the content of the document to understand where to insert the merge fields.
    - then use the mail merge feature to populate fields with data
- In the result document, the first row, which contains the name of the component, needs to be bold. The second row needs to contain an image, the logo of the component. The third row needs to contain text loaded from HTML.
- Save the files as "<ComponentName>.pdf". There should be 5 files at the end - one for each component.
After generating the code
- Build and execute the code, fix it if there are issues."

./benchmark-agents.sh "$PROMPT" "$N_RUNS" "Document" "$AGENTS"
