**Task: Create Minimal Ubuntu-Based Dev Docker Image (1-Page Plan)**

---

## Goal

Create a **company Docker image** based on **`ubuntu:24.04`** that installs core dev tooling + CLI agents, stays reasonably small, and is easy to maintain.
All Docker-related files live in a subfolder **`docker/`**.
Image should open in interactive bash, show installed versions, and start inside project folder.

---

## Folder Structure (inside repo root)

```
project-root/
├─ docker/
│  ├─ Dockerfile
│  ├─ install-base.sh
│  ├─ install-cli-agents.sh
│  ├─ display-versions.sh
│  ├─ build-image.sh
│  ├─ run-container.sh
│  └─ push-image.sh
└─ (all other project files…)
```

---

## Design Principles

* **Base:** `ubuntu:24.04` (LTS, stable, good MS/.NET compatibility)
* **Versions:** “latest available”, not pinned
* **Small scripts:** each install script <15 LOC, version script <10 LOC
* **Low maintenance:** use official vendor repos/npm, avoid custom binaries
* **Reasonable size:** clean apt and npm caches in same layer
* **Developer-friendly:** interactive shell on start

---

## Dockerfile Responsibilities

1. **FROM `ubuntu:24.04`**
2. Install minimal OS prerequisites (curl, git, ca-certificates, gnupg, unzip, bash).
3. **COPY entire parent project folder** into container path:
   `/gembox-skill`
4. Set `WORKDIR /gembox-skill`
5. Copy and execute:

   * `install-base.sh`
   * `install-cli-agents.sh`
6. Clean package caches to reduce size.
7. Default command when container runs:

   * execute `display-versions.sh`
   * then drop into interactive `bash`
   * remain in `/gembox-skill`

---

## Script Responsibilities

### `install-base.sh`  (<15 LOC)

Purpose: core system + runtimes.
Installs:

* Git
* Node.js + npm
* .NET SDK (latest preview allowed)
* PowerShell
* Any required OS libs
* Clears apt cache

No version pinning, no complex logic.

---

### `install-cli-agents.sh`  (<15 LOC)

Purpose: global npm / tool installs.
Installs via npm or vendor installers:

* Codex CLI
* GitHub Copilot CLI
* Claude Code CLI
* Any dependencies they need
* Clears npm cache

---

### `display-versions.sh`  (<10 LOC)

Purpose: sanity check.
Print versions for:

* dotnet
* git
* node / npm
* codex
* copilot
* claude
* pwsh

No formatting complexity.

---

## macOS Helper Scripts (1 line each)

### `build-image.sh`

* Builds Docker image with a fixed tag (e.g. `gembox/gembox-skill:latest`).

### `run-container.sh`

* Runs container interactively.
* Mounts parent folder `..` to `/gembox-skill`.
* Opens bash.

### `push-image.sh`

* Pushes tagged image to Docker Hub namespace `gembox`.

---

## Runtime Behavior

When user runs container:

1. Container starts in `/gembox-skill`
2. `display-versions.sh` executes automatically
3. Interactive bash shell remains open
4. User can continue working immediately

---

## Size & Maintenance Strategy

* Use Ubuntu LTS, not `latest`
* Combine apt installs into single layer
* Clean apt and npm caches
* Prefer official package sources
* Avoid manual downloads/checksums
* Keep scripts short and readable

---

## Expected Outcome

* Final image size roughly **700–1000 MB**
* Easy to rebuild
* Predictable behavior
* Minimal ongoing maintenance
* Suitable for customer download and internal dev use.

---

## Additional Requirements (Added from Shell Notes)

* Validate end-to-end behavior after changes by running:
  * `./build-image.sh`
  * `./run-container.sh`
  * verify displayed versions
  * run `ls` in container to confirm interactivity and mounted parent folder
* Ensure solution works on **amd64 host environments** (e.g., Windows 11 host with Docker on amd64), not only arm64.
* Create `<agentName>-summary.md` (max 1 page) that includes:
  * concise summary of what was done
  * reasoning behind each major decision
  * markdown table of file LOC in `docker/`
  * image size summary (architecture + exact bytes + GB approximation)
* Docker image must install the GemBox AI coding agent skill from `../gembox-skill` for all users in the image and expose it in skills listing (`/skills list` should include `gembox-skill`).
