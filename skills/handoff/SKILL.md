---
name: handoff
description: Commit and push the work plus a handoff document in .handoff/ to the git remote, so another session on any machine can resume with /pickup. Cancels if git or a remote is not set up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Hand the work over to a fresh agent, possibly on another machine, in a different harness or on a different model, which will resume it with the `pickup` skill. Local git state does not move between machines, so everything the next agent needs either travels through the git remote or is named to the user as something to copy by hand.

Write for a reader that has none of this session's context or memory: name commands, paths and decisions explicitly. If the user passed arguments, treat them as what the next session will focus on and tailor the document to it.

Invoking this skill is the user's request to commit and push the handoff. It does not override the project's other git rules: ask before pushing to the default branch if the rules say to branch first, and never force-push.

## Process

### 1. Check that a handoff is possible

Run these checks before writing anything. If any fails, cancel the handoff: tell the user which check failed and what to set up, and write nothing.

- The working directory is inside a git repository (`git rev-parse --show-toplevel`).
- A git identity is configured (`git config user.name` and `git config user.email` both non-empty).
- A remote exists (`git remote` is non-empty) and is reachable (`git fetch` succeeds).
- The current branch is not behind its upstream (`git status -sb`). If it is behind or has diverged, stop and ask the user how to reconcile; do not pull, rebase or merge on your own.

### 2. Decide what travels

- **Uncommitted changes.** List `git status --short`. Ask the user which of them belong to the work and should be committed with the handoff. Changes left out stay on this machine only; say so.
- **Artifacts outside git.** Work out which files the next steps and pointers depend on that git does not carry: checkpoints, datasets, results, caches, logs, local config such as `.env` files, and anything ignored (`git status --short --ignored`, `git check-ignore -v <path>`). For each, record its path, rough size, why the next steps need it, and where it must be placed on the next machine. Files that already live on a shared system (a cluster, a bucket) are recorded by location instead. Never copy secrets into the document; name the file only.

### 3. Capture the state

- Repository root, current branch, and the upstream it pushes to.
- Jobs still running: scheduler or process ID, where it runs, where its logs go, and the command that shows its status.
- The environment the work needs: virtual environment or conda env, key package versions, machine or cluster.

### 4. Write the document

Save it as `.handoff/<YYYYMMDD-HHMM>-<slug>.md` at the repository root, with the slug taken from the topic. `.handoff/` holds only handoffs not yet picked up; `pickup` moves consumed ones to `.handoff/done/`. If an earlier handoff is still waiting in `.handoff/`, ask the user whether the new one supersedes it; if so, move the old one to `.handoff/done/` in the same commit.

Use this structure, and leave no section out (write "none" where it applies):

```markdown
# Handoff: <topic>

Written <ISO 8601 date and time with timezone> by <harness and model> on <machine>. Next session: <focus>.

## State snapshot
- Repository: <remote URL>, branch `<branch>` (the handoff commit is the tip of this branch on the remote)
- Left uncommitted on the writing machine: <files, or none>
- Running jobs: <ID, where, log path, status command; or none>
- Environment: <env name, key versions, machine or cluster>

## Artifacts outside git
<for each: path, size, why it is needed, where to put it on the next machine; or none>

## Goal
## Done so far
## Decisions settled
<each decision, its reason, and where it is recorded>
## Open questions
<each question and who decides it>
## Next steps
<ordered; each with how to tell it is done>
## Pointers
<files, experiment records, commits, URLs>
## Suggested skills
<skills the next agent should load, if its harness has them>
```

Reference artifacts that already exist in git (plans, experiment records, commits, issues) by path or URL instead of copying them. Redact credentials such as API keys and passwords. Point to where data lives and how to access it rather than copying its contents.

### 5. Commit and push

1. Commit the work the user chose in step 2, if any, with a message describing that work.
2. Commit the handoff document in a commit of its own (`Handoff: <topic>`).
3. Push the branch (`git push`, or `git push -u origin <branch>` if it has no upstream). If the push is rejected, stop and report; do not force-push, rebase or merge without the user.
4. Confirm the remote has the handoff commit (`git status -sb` shows the branch in sync).

### 6. Tell the user

Say plainly: the handoff file's path, the branch and remote it was pushed to, and how to resume (`/pickup` in a session on the target machine, after cloning or fetching the repository). Then list every artifact outside git, with where it is now and where it must go, as something the user has to copy by hand before resuming. If there are none, say so.
