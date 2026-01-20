## Skill for CLI coding agents (Copilot / Claude Code / Codex)

This package ships a ready-to-install [Agent Skill](https://agentskills.io) named "gembox-skill". Instructions for popular coding agents are below.

**A. GitHub Copilot**
1. Copy the entire `gembox-skill/` folder to: 

   `~/.copilot/skills/` (personal skills)

   OR 

   `[project-root]/.github/skills/` (project skills)

2. Check that "gembox-skill" is enabled with: 
   
   `copilot -i "/skills list"`

**B. Claude Code**
1. Copy the entire `gembox-skill/` folder to: 

   `~/.claude/skills/` (personal skills)

   OR

   `[project-root]/.claude/skills/` (project skills)

2. Check that "gembox-skill" is enabled with: 

   `claude /skills`

**C. Codex**

1. Copy the entire `gembox-skill/` folder to: 

   `~/.codex/skills/` (personal skills)

   OR

   `[project-root]/.codex/skills/` (project skills)

2. Until Codex adds a CLI option to check skills, use this to check that "gembox-skill" is enabled:

   `codex e "Display the version of gembox-skill?" --skip-git-repo-check`

Once you have "gembox-skill" installed, your coding agent will use that skill to search GemBox documentation and examples when generating GemBox code.
