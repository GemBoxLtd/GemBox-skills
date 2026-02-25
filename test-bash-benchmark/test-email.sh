#!/usr/bin/env bash

N_RUNS="${1:-1}"

PROMPT="Generate C# code, together with project files for opening in VSCode, that uses GemBox.Email 2026.2.100 and .NET 10. 
That C# code should:
- Create a new email and save it to a local file in MSG format.
- The email body should be formatted in HTML.
- The email will contain information about GemBox.Email features in two sections.
- The section titles must be bold and have a greater font size compared to the rest of the content.
- The first section will list the main features in bullet points. Read https://www.gemboxsoftware.com/email content to find which features GemBox.Email have.
- The second section will list the latest added features and bug fixes in bullet points. Go to https://www.gemboxsoftware.com/news and find the latest post.
- At the end of email's body, include an inline image attachment containing the GemBox logo. You can fetch it from https://www.gemboxsoftware.com/img/company/logo.svg.
- You need to set the image height to 40px and keep the width proportional to it in order to keep the aspect ratio.
- Right above the GemBox logo, list in a short sentence all skills used in this task, or 'No skills' if none were used. e.g.: "Skills used to compose this email: example-skill-a and example-skill-b".
- After saving the .MSG file, the program should read the generated file and confirm that all elements are there correctly (subject, image inline attachment and HTML body.)
- Print to the console whether the final validation succeeded or failed. In case of failures, print what is missing or wrong.
After generating the code:
- Build and execute the code, fix it if there are issues."

./benchmark-agents.sh "$PROMPT" "$N_RUNS" "Email" 
