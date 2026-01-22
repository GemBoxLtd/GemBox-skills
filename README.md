## Skill for CLI coding agents (Copilot/Claude/Codex)

This package contains a ready-to-install [Agent Skill](https://agentskills.io) named "gembox-skill" that provides coding assistance for [GemBox components](https://www.gemboxsoftware.com/).

To install, copy the entire `gembox-skill/` folder to your agent skills install path (see the list below). Restart your coding agent and then type `/skills list` in the interactive mode to verify the skill is available.

Once installed, your coding agent will use "gembox-skill" automatically when generating GemBox code. You can invoke skill manually with `/gembox-skill` (Copilot and Claude) and `/skills gembox-skill` (Codex).


### Coding agents paths 

* A. GitHub Copilot
  * Personal skills install path
    * Windows: `%USERPROFILE%\.copilot\skills\`
    * Linux/macOS: `~/.copilot/skills/` 
  * Repository skills install path: [Read more in GitHub docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills#about-agent-skills)

* B. Claude Code
  * Personal skills install path
    * Windows: `%USERPROFILE%\.claude\skills\`
    * Linux/macOS: `~/.claude/skills/` 
  * Enterprise/Project/Plugin skills install path: [Read more in Claude docs](https://code.claude.com/docs/en/skills#where-skills-live)

* C. OpenAI Codex
  * Personal skills install path
    * Windows: `%USERPROFILE%\.codex\skills\`
    * Linux/macOS: `~/.codex/skills/`
  * Repository/Admin skills install path: [Read more in OpenAI docs](https://developers.openai.com/codex/skills)
