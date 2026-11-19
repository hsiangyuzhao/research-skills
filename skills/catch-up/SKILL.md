---
name: catch-up
description: Bring the user back into a research project after a pause on the same machine. Retell the story top-down from NARRATIVE.md, then what happened while they were away, then the current state and the decisions waiting. Read-only. Use when the user returns after days or weeks away, says they have forgotten where things stand, or asks for a catch-up, a brief or an overall progress report. To move work to another machine or session, use pickup instead.
---

# Catch up

There are two kinds of return, and they fail in different ways:

- **After a pause, same machine.** The repository, environment and artifacts are all here; what is missing is in the user's head. They have forgotten the story and many details, and will naturally restart from "where were we" instead of "why are we doing this". This skill is for that case.
- **On another machine or in another session.** The user remembers the work; the repository, artifacts and running jobs have to be brought over and checked. That is `pickup`, which fetches and pushes through git.

After a long pause on a new machine, run `pickup` first, then this skill.

This skill is read-only. Do not fetch, pull, commit, push, submit or cancel jobs, or edit NARRATIVE.md. Propose changes; the user decides.

## Process

### 1. Fix the period

Establish when the user was last active: ask, or take it from the latest commit or record entry they made, and state the period you are covering. Everything in step 3 is limited to this period.

### 2. Read the story

Read `NARRATIVE.md` at the repository root (format in the `research-narrative` skill). If it is missing, say so, and offer to draft one from the project records for the user to correct; continue with what the records give, marked as your reading.

Then check whether it is current. Compare its last change (`git log -1 -- NARRATIVE.md`) with the record entries after it, and list what the story does not yet reflect:

- results that changed which gap or contribution the evidence supports;
- a turn to a new micro story;
- a micro story or a gap and contribution still marked as an agent draft.

### 3. Gather what happened in the period

From the project's own records: the git log, the decision register and the experiment records for the period, money or compute spent against approved budgets, jobs that ran or are running (status only, through the commands the project records), and decisions left open. Read the files; do not rerun anything.

### 4. Write the brief

In this order:

1. **The story.** The macro frame in two or three sentences; the micro stories tried, in order, each with what ended it and what it taught; the current micro story, whether the user has confirmed it, and its evidence. This part should read like the Introduction of a paper, not like a changelog, and fit on one screen. Point to records for numbers rather than listing them.
2. **While you were away.** The events of the period, each tied to the part of the current micro story it served (a forward test, or strengthening or repositioning it), or marked as tied to none. The story items from step 2 that NARRATIVE.md does not yet reflect go here.
3. **State.** Running or finished jobs, resources and budgets, unpushed or uncommitted work, dates that have moved.
4. **Decisions waiting.** Each with the part of the story it serves.

The test of the brief: from it alone, the user can restate the research gap and choose the next step.

### 5. Wait

Do not resume engineering work until the user has confirmed the story or chosen the next step. If the current micro story, or its gap and contribution, is still an agent draft, or the story is stale, ask for that confirmation first: spending on a story only the agent wrote is how a project drifts.
