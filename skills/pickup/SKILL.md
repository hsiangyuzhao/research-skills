---
name: pickup
description: Resume work from a handoff. Inside the repository, fetch the latest handoff from the git remote; outside any repository, restore the repository named in a handoff file it can read. Then check the snapshot and the artifacts outside git on this machine, and continue. Cancels if git is not set up or the remote cannot be reached.
argument-hint: "Path to a handoff file (optional; defaults to the pending one in .handoff/)"
disable-model-invocation: true
---

Resume work that an earlier session handed over with the `handoff` skill, possibly from another machine. The handoff travels through the git remote, so start from the remote, then find out how much of the recorded state holds here, and only then continue.

Invoking this skill is the user's request to fetch (or restore the repository), fast-forward and push the pickup commit. It does not override the project's other git rules: never force-push, and ask before any rebase or merge.

## Process

### 1. Check that a pickup is possible

If any of these fails, cancel: tell the user which check failed and what to set up.

- A git identity is configured (`git config user.name` and `git config user.email` both non-empty). Never invent one.
- The working directory is inside a git repository (`git rev-parse --show-toplevel`). If it is not, but a handoff file can be read (the path the user passed, or a Markdown file in the working directory whose first line starts with `# Handoff:`; if several, ask which), restore the repository from it first (step 1a).
- A remote exists (`git remote` is non-empty) and is reachable (`git fetch` succeeds).

### 1a. Restore the repository from a handoff file

Use this when the working directory is not a git repository but holds or is given a handoff file. Other files in the directory are fine.

1. Read the handoff. Its State snapshot must name the remote URL and the branch; if either is missing, cancel.
2. Set up the repository in the working directory: `git init`, `git remote add origin <remote URL>`, `git fetch origin <branch>`. If the fetch fails (authentication, network, missing branch), remove the `.git` directory this step created, report the error, and cancel.
3. Find conflicts: files already in the directory at a path the branch also tracks (`git ls-tree -r --name-only origin/<branch>`). A file whose content is identical to the tracked version (`git show origin/<branch>:<path>`) is not a conflict. List every real conflict and let the user decide, per file, whether to keep the local version, take the repository's, or move the local one aside. Do not overwrite or delete anything before they decide.
4. Check out the branch (`git checkout -b <branch> --track origin/<branch>`), after moving aside identical copies and applying the user's decisions so the checkout does not refuse. Files that are not in the repository stay as untracked files; tell the user which.
5. Continue at step 2, inside the restored repository. The handoff to follow is the one under `.handoff/` on the branch; if it differs from the file you were given, tell the user and ask which to follow.

### 2. Bring the checkout up to date

The handoff names a branch; if you do not know it yet, find the pending handoff on the remote first (`git log --all --oneline -- .handoff/` lists the commits that touched it).

- Switch to that branch, creating a local tracking branch if needed.
- If the local branch is behind its upstream, fast-forward it (`git pull --ff-only`). If there are uncommitted local changes in the way, or the branches have diverged, stop and ask the user; do not stash, reset, rebase or merge on your own.

### 3. Find the handoff

If the user passed a path, use it. Otherwise look for files directly under `.handoff/` (not in `.handoff/done/`).

- Exactly one: use it.
- Several: list them with their dates and topics and ask which one.
- None: say there is nothing to pick up and stop.

### 4. Read it in full

Read the whole document before running anything. Then read the files it points to that the next steps depend on.

### 5. Check the snapshot against this machine

Report each item as matching, changed, or not checkable:

- **Branch**: the handoff commit is at or below the tip of the recorded branch. Commits after it mean work happened after the handoff; list them.
- **Left uncommitted on the writing machine**: those changes are not here. Say which next steps depend on them.
- **Artifacts outside git**: check each recorded artifact at its expected path. List every missing one explicitly, with where it was on the writing machine and where it must go here, and ask the user to copy it. Do not start a next step that needs a missing artifact.
- **Running jobs**: run each recorded status command and report whether the job is running, finished or failed, and where its output is. Checking status is fine; do not resubmit, cancel or rerun anything.
- **Environment**: confirm the recorded environment exists here and activate it if the project expects that. Report anything missing.
- **Pointers**: confirm the referenced files exist.

### 6. Report and wait

Tell the user, briefly: the goal, what was done, every mismatch and missing artifact from step 5, the open questions, and the first next step as you now understand it. Do not start the next steps until the user confirms and every artifact those steps need is in place.

### 7. Mark it picked up, push, and continue

Once the user confirms:

1. Move the handoff into `.handoff/done/` with `git mv` and commit that on its own (`Pick up handoff: <topic>`).
2. Push it, so other machines see the handoff as consumed. If the push is rejected, stop and report; do not force-push.
3. Call the Skill tool for each model-invoked skill listed under Suggested skills that this harness has; for user-invoked ones, tell the user to run them.
4. Work through the next steps.
