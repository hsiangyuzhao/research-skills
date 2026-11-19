---
name: research-narrative
description: Keep a research project's funnel narrative (macro frame, current micro story, earlier micro stories) present during long work, and lead with it when the user returns. Use when a new route, method or micro hypothesis is proposed by either side; when a result changes which gap or contribution the evidence supports; when asking the user to decide (a choice, an approval, a budget) during long work; when the user returns after a pause or asks for a catch-up, an overall progress report or a gap-level review of recent work; and when creating or updating a project's NARRATIVE.md.
---

# Research narrative

Research code serves a funnel: background, a concrete research question, its motivation, the research gap, and the work that answers the gap as a contribution. Engineering state means something only inside that funnel. Two failures follow when the funnel drops out of view:

- **Drift during long work.** Each step is reasonable and approved, yet the line of work stops answering the gap: a local optimum in engineering correctness, data quality or significance, or a story the agent wrote that nobody confirmed. Neither side notices, because no single step shows it.
- **Regression on return.** After a pause, only the engineering state is left, so the conversation restarts from "where were we" instead of "why are we doing this".

The agent usually knows the story; asked directly, it can state it. What it lacks is the occasion to bring it up unprompted. This skill supplies the occasions and the place the story lives. Terms are defined in [references/glossary.md](references/glossary.md), with the user's Chinese terms.

## The model

- **Macro frame.** The background, the broad problem and its negative constraints. Example: "make language models use evidence buried deep in long contexts, with gains that do not come from the answer leaking into the prompt." It rarely changes, and only the user changes it, usually by clarifying its boundary.
- **Micro story.** One concrete hypothesis with its motivation, gap, contribution and experiments. A small change in the hypothesis gives a different paper. Micro stories are expected to change.
- **Two directions.** Forward derivation goes from hypothesis to gap, contribution and experiment. Reverse look-back goes from results back to the gap and contribution that explain them, and sets the paper's narrative. Both are normal research practice; reverse look-back is not a breach of claim discipline.
- **Sources of change.** The user changes micro stories with new ideas or in response to results; these changes are known to the user and stated. The agent's drift is the unknown kind.
- **Telling them apart.** Ask which level a change touches and who confirmed the story:
  - Reasonable deepening: detailed work that tests or strengthens a micro story the user confirmed.
  - Turn or pivot: the micro story itself is replaced, by the user, inside the macro frame.
  - Drift: work running without a confirmed micro story, under a story only the agent wrote, or along a route that cannot separate the effect the macro frame cares about from its obvious alternatives.

Measure drift against the macro frame and the current confirmed micro story, never against a fixed plan; a fixed plan turns every legitimate turn into an alarm.

## The anchor: NARRATIVE.md

One file at the repository root, owned by the user, linked first from the README and from the project's rules file. The agent drafts changes; the user confirms them.

```markdown
# Narrative

## Macro frame
<background and broad problem, in the user's words>
<negative constraints, e.g. "gains must not come from the answer leaking into the prompt">
<separability requirement: what alternative explanations a result must exclude>

## Current micro story (confirmed by the user on <date> | agent draft)
- Hypothesis:
- Motivation:
- Gap:
- Contribution:
- Evidence so far: <one line per experiment, pointing to the decision register or ledger entry>
- Open: <what would confirm, strengthen or end this story>

## Earlier micro stories
### <short name> (<dates>)
- Hypothesis and gap it targeted:
- What ended or reshaped it: <result, with pointer>
- What it taught:
```

Rules:
- In Claude Code, the `narrative-hook-claude-code` skill installs a hook that re-injects the macro frame and current micro story from this file after every context compaction.
- Point to experiment records; do not copy numbers or protocols. The anchor holds only the layers above the claim.
- When a micro story ends, move it to "Earlier micro stories" with what ended it. Never overwrite it; the sequence of attempts is the story a returning reader needs.
- Project rule files and READMEs reference the anchor instead of restating the story, so they do not go stale at each turn.
- Creating the anchor: ask the user to state the macro frame in their own words. A frame reconstructed from artifacts alone tends to centre on the latest instance, or on the wrong question. Draft the micro stories from the records and mark them as drafts.

## Forward act: when a micro story or route is proposed

Whoever proposes it, before experiments are designed:

1. Write the micro story in anchor form as a draft: hypothesis, gap, contribution, the experiment that would test it.
2. Answer in one sentence: can this route, even in principle, separate the effect the macro frame cares about from its obvious alternatives? If not, say so now.
3. Hand it to the user. The act states; it does not block the user's ideas.

Example: replacing the model under study with a larger one passes a local test ("the larger model finds the evidence more often") but cannot separate better use of long contexts from more capacity; continued, it converges to an ordinary scaling result. Step 2 says this before the first run.

## Reverse act: when a result moves the story

Trigger: a result changes which gap or contribution the evidence supports, or a forward test has passed and the next work is to strengthen it. Not every result; result-by-result reading of the claim is already part of claim discipline.

1. Propose the gap and contribution the results now support, with every result kept in view, unfavourable ones included.
2. If the story is repositioned, name the forward check that would confirm the new position on data that played no part in choosing it.
3. The user decides. Until then, code, configs and text stay at the current story.

Example: the method beats a matched control on the development set, but on a held-out domain the margin shrinks and both trained arms score below the starting checkpoint. The reverse act asks whether "better than the starting checkpoint" is part of the contribution, and what the next data work is for: a cleaner test of the matched contrast, or a gain over the starting checkpoint. Building harder training data to strengthen a confirmed result is legitimate reverse work; doing it without saying which it serves is how drift starts.

Organising the paper around the results that turned out favourable is a reverse look-back at the micro level. It is legitimate as long as the macro frame is unchanged, every result is reported, and the scope is named by a mechanism. Do not treat it as a violation.

## One line at every decision point

Whenever you ask the user to decide during long work (a choice dialog, an approval, a budget, a rerun), add one line naming the part of the current micro story the decision serves, and whether it is a forward test or reverse strengthening or repositioning.

- Good: "Serves the current story's test that the method beats the matched control on held-out documents (forward)."
- Not acceptable: "Serves the project." A line that names no specific part of the story is a missing link.

If the honest answer is that the decision serves no part of a confirmed micro story, or serves a story only you wrote, that is the look-back: say so in two or three sentences at the gap level, and let the user choose between continuing, writing the story, or stopping. This is the only interruption the skill adds. No timers, step counts or periodic reminders.

## Returns, catch-ups and progress reports

Open with the story, then the state, as the `catch-up` skill sets out: the macro frame, the micro stories tried with what ended each, the current micro story and its evidence, and only then the engineering state and the decisions waiting. The story part reads like the Introduction of a paper, not like a changelog. A return after a pause runs `catch-up` itself; a progress report or a user-requested gap-level review of a period follows the same order, and the review adds the decision-point lines of that period, showing which work served which part of the story. A move to another machine is `pickup`, which carries the engineering state and does not replace this.

## Do not

- Treat the user's turns, or a local narrative choice, as drift.
- Change the macro frame or mark a micro story as confirmed without the user.
- Copy results into the anchor, or let it grow into a second decision register.
- Repeat the look-back after the user has chosen; record the choice and continue.
