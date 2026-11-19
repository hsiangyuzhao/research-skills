# Research Skills

English | [简体中文](./README.zh-CN.md)

Standing rules and agent skills for doing research with coding agents, for people who work on large language models and their downstream applications. Each skill is a folder under [`skills/`](./skills) with a `SKILL.md`, in the Agent Skills format that Claude Code, Codex and other harnesses read. Several general skills are adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (v1.3.1, commit `f3fc563`), reshaped for research code rather than product engineering.

## How we do research with a coding agent

**Roles.** The researcher owns the project, makes every scientific decision and is the final named author. The agent implements the researcher's core idea with necessary and sufficient engineering, verifies it, and packages the result as a claim that withstands scrutiny.

**Three layers.** Research work sits in three layers, and each means something only inside the one above it:

1. **Narrative.** The funnel a paper argues in: background, a concrete research question, its motivation, the research gap, and the contribution that answers the gap. It has two levels.
   - The **macro frame** is the background, the broad problem and its negative constraints (what the work must not rely on). It rarely changes, and only the researcher changes it.
   - The **micro story** is one concrete hypothesis with its own motivation, gap, contribution and experiments. A small change in the hypothesis gives a different paper, so micro stories are expected to change.
2. **Claim.** What the work asserts, always inside an explicit scope: the defensible special case, named by a mechanism or a dimension, rather than an unattainable general case.
3. **Engineering.** Code, experiments, data, jobs and records. Correct engineering that serves no claim is wasted; correct engineering that serves a claim nobody needs is drift.

**Both directions.** At the micro level, motivation, gap, contribution and experiment are not a one-way chain. Forward derivation goes from a hypothesis to the experiment that tests it. Reverse look-back goes from results to the gap and contribution that explain them, and sets the paper's narrative. Both are normal research practice.

**Who changes what.** The researcher changes micro stories, with new ideas or in response to results, and knows when they do. The researcher alone moves the macro frame or narrows a claim. The agent proposes; it does not decide.

## What goes wrong when a coding agent does research

Coding agents are trained largely on product engineering, and their habits fail in research in ways that are silent: the result looks normal and is wrong, or right and irrelevant. The failures appear at each layer.

**Engineering.**
- Failures disguised as plausible data: a missing value replaced with a default, a parse failure with an empty string, an API error retried silently. The numbers look normal and are wrong.
- Engineering aimed at the wrong target: the smallest diff instead of the clearest final state, abstractions for hypothetical needs, ritual unit tests, dry-runs and hash checks where none are needed, and too few checks at the seams where an error is silent (masks, alignment, metrics, splits).

**Claim.**
- Claims weakened silently ("improves" becomes "may help"), poor settings dropped, scopes picked after the fact from subsets that looked good.
- Deliverables padded with sentences that shield the author ("this does not imply...", "results are preliminary") instead of stating the scope inside the claim.

**Narrative.** This is the layer the agent loses most easily, because no single step shows it.
- **Drift during long work.** The agent settles into a local optimum (engineering correctness, data quality, statistical significance) and the line of work stops answering the gap. Every step was reasonable and approved, so the researcher does not notice either. A related form: the agent writes a micro story of its own, a route that passes its local test but cannot separate the effect the macro frame cares about from its obvious alternatives, and work continues under it without the researcher ever confirming it.
- **Agent-initiated look-back is missing.** Asked directly, the agent can state the story accurately. Unprompted, it reads each new result against the claim, but it does not ask whether the current line of work still serves the gap. In practice every look-back at that level is started by the researcher.
- **The opposite error.** An agent that reads the claim rules as forward-only treats a legitimate reverse look-back, or the researcher's own turn to a new micro story, as a violation, and interrupts sound work.
- **Regression on return.** After a pause, the agent's catch-up is a changelog of what was done, and entry documents (README, handoff, the story row of a decision register) record the instance of the day in place of the story. Context compaction keeps the claim sentence at best and drops the gap.

**Continuity.** Moving work to another machine loses repository and artifact state; returning after a pause loses the story and details in the researcher's head. The two need different handling.

## How this repository addresses them

**Standing rules.** [AGENTS.md](./AGENTS.md) holds the rules for every layer: delegation to subagents, implementation, failures and fallbacks, experiments and claims, the research narrative, deliverables, tests, cost and git. Use it as a global instruction file (`~/.claude/CLAUDE.md` for Claude Code, `~/.codex/AGENTS.md` for Codex) or as a project's `AGENTS.md`. It is loaded in every session, so its rules survive context compaction. The `research-dev-discipline` skill is its fuller interpretation.

**Engineering and claim.** `research-dev-discipline` gives the reasoning and edge cases behind the rules: fail loudly, aim for the clearest final state, keep the claim's scope explicit, record failures before narrowing, write deliverables from the researcher's standpoint. `diagnosing-bugs` and `correctness-tests` cover silent bugs and the few tests that matter. `spec-review` checks a diff against the method section or experiment plan. `grilling` stress-tests a plan or a framing. `git-guardrails-claude-code` puts a deterministic approval step in front of git commands with no undo.

**Narrative.** `research-narrative` keeps the story present without adding reminders on a timer:
- A user-owned `NARRATIVE.md` at the project root holds the macro frame, the current micro story (marked as confirmed by the researcher or as an agent draft) and the earlier micro stories with the result that ended each. It points to experiment records instead of copying them, and project rule files reference it instead of restating the story.
- **Forward act.** When either side proposes a new route, the agent drafts its micro story and answers one question before experiments are designed: can this route, even in principle, separate the effect the macro frame cares about from its obvious alternatives?
- **Reverse act.** When a result changes which gap or contribution the evidence supports, the agent proposes the repositioned gap and contribution, with every result kept in view, and names the forward check that would confirm it. The researcher decides.
- **One line at every decision point.** Whenever the agent asks the researcher to decide, it names the part of the current micro story the decision serves. When it cannot, that is the look-back: it says so at the gap level and lets the researcher choose. This uses moments that already exist and interrupts only when the link is missing, which is what drift looks like.
- Drift is measured against the macro frame and the confirmed micro story, never against a fixed plan, so the researcher's turns and reverse look-backs are not flagged.
- A glossary gives each term with the researcher's Chinese equivalent, so both languages refer to the same concepts.

`narrative-hook-claude-code` installs a Claude Code hook that re-injects the macro frame and the current micro story from `NARRATIVE.md` after every compaction, whatever the summary kept.

**Continuity.** `catch-up` handles a return after a pause on the same machine: read-only, it retells the story top-down, then what happened in the period and how each event served the story, then the state and the decisions waiting, and waits for the researcher to confirm the story. `handoff` and `pickup` move the engineering state between machines or sessions through the git remote; a handoff records which part of the current micro story the work serves.

## Skills

**User-invoked** skills run only when you type them (e.g. `/spec-review`). **Model-invoked** skills can also be picked up by the agent when the task fits.

### General

Research and engineering skills that apply to any project.

**Model-invoked**

- **[research-dev-discipline](./skills/research-dev-discipline/SKILL.md)**: The fuller interpretation of the research rules in [AGENTS.md](./AGENTS.md), with the reasoning, examples and edge cases behind each one. Loaded when brainstorming, at scientific or experimental checkpoints you set, when delivering experimental artifacts, and when interpreting a failed or surprising result.
- **[research-narrative](./skills/research-narrative/SKILL.md)**: Keeps the funnel narrative present in long research work: a user-owned `NARRATIVE.md` with the macro frame, the current micro story and the earlier ones; a forward check when a route is proposed, a reverse look-back when results move the story, one line at each decision point naming the part of the story it serves, and story-first returns and progress reports. Includes a glossary of the terms with their Chinese equivalents.
- **[catch-up](./skills/catch-up/SKILL.md)**: Bring you back into a project after a pause on the same machine: the research story top-down from `NARRATIVE.md`, then what happened while you were away, the current state and the decisions waiting. Read-only; waits for you to confirm the story or choose the next step. For moving to another machine, use `pickup`.
- **[diagnosing-bugs](./skills/diagnosing-bugs/SKILL.md)**: Diagnosis loop for hard and silent bugs in research code: build a fast signal that goes red on this bug, minimise, hypothesise, instrument, fix with a regression test, and name any results that need re-running.
- **[correctness-tests](./skills/correctness-tests/SKILL.md)**: The few tests research code needs, at seams where a silent error changes results (metrics, transforms, splits, preprocessing, losses), each checked against an independent oracle.
- **[grilling](./skills/grilling/SKILL.md)**: Relentless interview about a plan, experiment design, paper framing, proposal or rebuttal, in rounds of questions with a recommended answer each. Facts are the agent's job, decisions are yours. Pins down vague terms, checks your claims against the code, and makes sure the evaluation protocol is covered.

**User-invoked**

- **[git-guardrails-claude-code](./skills/git-guardrails-claude-code/SKILL.md)**: Install, once per machine, a Claude Code hook that asks for your approval before any git command with no undo (clean, hard reset, discarding uncommitted changes, dropping stashes, force push).
- **[narrative-hook-claude-code](./skills/narrative-hook-claude-code/SKILL.md)**: Install a Claude Code hook that re-injects the Macro frame and Current micro story from `NARRATIVE.md` into the context after every compaction.
- **[spec-review](./skills/spec-review/SKILL.md)**: Check that the diff since a fixed point does what the paper's method section, experiment plan or issue says: data splits, preprocessing, model and training settings, metric computation.
- **[handoff](./skills/handoff/SKILL.md)**: Commit and push the work and a handoff document (state snapshot, decisions, open questions, next steps, artifacts to copy by hand) to the git remote, for any harness or model on any machine to pick up. Cancels without git or a remote.
- **[pickup](./skills/pickup/SKILL.md)**: Resume from a handoff: fetch it from the git remote inside the repository, or restore the repository it names from a copied handoff file when run outside one (asking you about any conflicting files). Then check its snapshot and the artifacts outside git on this machine, report mismatches, and continue once you confirm. It moves the engineering state; after a long pause, follow it with `catch-up`.
- **[to-questionnaire](./skills/to-questionnaire/SKILL.md)**: Turn a decision you can't make alone into a questionnaire for the one person who can (a clinical collaborator, say), written in their vocabulary.

### Domain

Skills for one research direction, each with a knowledge base under `references/`.

**Model-invoked**

- **[opd-research-coding](./skills/opd-research-coding/SKILL.md)**: On-policy distillation (OPD, OPSD, OPD+RLVR) research coding: pre-flight diagnostics, loss and estimator design, required logging, symptom to cause to fix tables, and experiment-design controls, backed by a knowledge base of 2026 OPD papers.

## Conventions

- Skills are written in English, with no em-dashes.
- The README exists in English (`README.md`) and Simplified Chinese (`README.zh-CN.md`), linked to each other at the top. Change both together.
- Invocation is the same in every harness. A user-invoked skill sets `disable-model-invocation: true` in `SKILL.md` (Claude Code) and `policy.allow_implicit_invocation: false` in `agents/openai.yaml` (Codex); a model-invoked skill sets neither. Change both together.

## License

MIT; see [LICENSE](./LICENSE). Adapted from mattpocock/skills, and keeping Matt Pocock's copyright: `diagnosing-bugs`, `correctness-tests` (from `tdd`), `grilling`, `git-guardrails-claude-code`, `spec-review` (from `code-review`), `handoff`, `to-questionnaire`. Original to this repo: `research-dev-discipline`, `research-narrative`, `catch-up`, `narrative-hook-claude-code`, `pickup`, `opd-research-coding` and `AGENTS.md`.
