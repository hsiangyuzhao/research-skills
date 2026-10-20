# Research Skills

Agent skills for people who conduct research on large language models and their downstream applications. Each skill is a folder under [`skills/`](./skills) with a `SKILL.md`, in the Agent Skills format that Claude Code, Codex and other harnesses read.

Several general skills are adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (v1.3.1, commit `f3fc563`), reshaped for research code rather than product engineering.

**User-invoked** skills run only when you type them (e.g. `/spec-review`). **Model-invoked** skills can also be picked up by the agent when the task fits.

## Working principles

[AGENTS.md](./AGENTS.md) holds standing rules for coding agents in research projects: delegation to subagents, implementation, failures and fallbacks, experiments and claims, deliverables, tests, cost and git. Use it as a global instruction file (`~/.claude/CLAUDE.md` for Claude Code, `~/.codex/AGENTS.md` for Codex) or as a project's `AGENTS.md`. The `research-dev-discipline` skill is its fuller interpretation.

## General

Research and engineering skills that apply to any project.

**Model-invoked**

- **[research-dev-discipline](./skills/research-dev-discipline/SKILL.md)**: The fuller interpretation of the research rules in [AGENTS.md](./AGENTS.md), with the reasoning, examples and edge cases behind each one. Loaded when brainstorming, at scientific or experimental checkpoints you set, when delivering experimental artifacts, and when interpreting a failed or surprising result.
- **[diagnosing-bugs](./skills/diagnosing-bugs/SKILL.md)**: Diagnosis loop for hard and silent bugs in research code: build a fast signal that goes red on this bug, minimise, hypothesise, instrument, fix with a regression test, and name any results that need re-running.
- **[correctness-tests](./skills/correctness-tests/SKILL.md)**: The few tests research code needs, at seams where a silent error changes results (metrics, transforms, splits, preprocessing, losses), each checked against an independent oracle.
- **[grilling](./skills/grilling/SKILL.md)**: Relentless interview about a plan, experiment design, paper framing, proposal or rebuttal, in rounds of questions with a recommended answer each. Facts are the agent's job, decisions are yours. Pins down vague terms, checks your claims against the code, and makes sure the evaluation protocol is covered.

**User-invoked**

- **[git-guardrails-claude-code](./skills/git-guardrails-claude-code/SKILL.md)**: Install, once per machine, a Claude Code hook that asks for your approval before any git command with no undo (clean, hard reset, discarding uncommitted changes, dropping stashes, force push).
- **[spec-review](./skills/spec-review/SKILL.md)**: Check that the diff since a fixed point does what the paper's method section, experiment plan or issue says: data splits, preprocessing, model and training settings, metric computation.
- **[handoff](./skills/handoff/SKILL.md)**: Commit and push the work and a handoff document (state snapshot, decisions, open questions, next steps, artifacts to copy by hand) to the git remote, for any harness or model on any machine to pick up. Cancels without git or a remote.
- **[pickup](./skills/pickup/SKILL.md)**: Resume from a handoff: fetch it from the git remote inside the repository, or restore the repository it names from a copied handoff file when run outside one (asking you about any conflicting files). Then check its snapshot and the artifacts outside git on this machine, report mismatches, and continue once you confirm.
- **[to-questionnaire](./skills/to-questionnaire/SKILL.md)**: Turn a decision you can't make alone into a questionnaire for the one person who can (a clinical collaborator, say), written in their vocabulary.

## Domain

Skills for one research direction, each with a knowledge base under `references/`.

**Model-invoked**

- **[opd-research-coding](./skills/opd-research-coding/SKILL.md)**: On-policy distillation (OPD, OPSD, OPD+RLVR) research coding: pre-flight diagnostics, loss and estimator design, required logging, symptom to cause to fix tables, and experiment-design controls, backed by a knowledge base of 2026 OPD papers.

## Conventions

- Skills are written in English, with no em-dashes.
- Invocation is the same in every harness. A user-invoked skill sets `disable-model-invocation: true` in `SKILL.md` (Claude Code) and `policy.allow_implicit_invocation: false` in `agents/openai.yaml` (Codex); a model-invoked skill sets neither. Change both together.

## License

MIT; see [LICENSE](./LICENSE). Adapted from mattpocock/skills, and keeping Matt Pocock's copyright: `diagnosing-bugs`, `correctness-tests` (from `tdd`), `grilling`, `git-guardrails-claude-code`, `spec-review` (from `code-review`), `handoff`, `to-questionnaire`. Original to this repo: `research-dev-discipline`, `pickup`, `opd-research-coding` and `AGENTS.md`.
