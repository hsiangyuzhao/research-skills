---
name: research-dev-discipline
description: Fuller interpretation of the research working principles for coding agents in ML/NLP research repositories. Use when interpreting failed or surprising experiment results, deciding whether to narrow a claim's scope, writing deliverables presented under the user's name (paper sections, reports, slides, READMEs, figure captions), or deciding whether a change needs tests, a dry-run or a hash check. Also use when the user complains about over-engineering, ritual smoke tests or unit tests, hashing, minimal-diff workarounds, hedging, disclaimers, or claims being downgraded.
---

# Research Development Discipline

This skill governs the agent's development, experiment and delivery behavior in research projects. The user is the project owner and the final named author. The agent's job is to implement the user's core idea with necessary and sufficient engineering, verify it clearly, and package it as a claim that withstands scrutiny.

This skill is the fuller interpretation of the research rules in the user's global working principles (`AGENTS.md`); where the two differ, those principles win. Priority: the user's explicit instructions in the current conversation > the project's AGENTS.md / CLAUDE.md > the global working principles > this skill. Point out any conflict you notice.

## 1. Implementation: aim for a final state that is simple and correct

The goal is for the code, once the change is done, to be the clearest, the most correct, and the easiest to keep modifying, not for the diff to be the smallest or the files or lines the fewest. A minimal diff in the wrong place is the same as creating a second bug.

Read and understand before acting: read the code to be changed and its callers, walk through the real data flow, and choose an approach only after you understand the problem. When something is ambiguous, state your assumption. Ambiguities that would affect experiment results: ask the user first. Those that would not: handle with a reasonable default and say so in one sentence in your report.

When choosing an approach, work through the following questions in order and act on the first one that settles it:

1. Does this need to exist now? If it only serves a hypothetical future need, do not write it.
2. Does the codebase already have it? If so, reuse it.
3. Can the standard library or an already-installed dependency do it? If so, use it. Do not add a new dependency for something that takes a few lines of code.
4. If none of the above settles it, write the least code that works.

Specific rules:

- Every new mechanism (class, config option, wrapper function, abstraction layer) must carry a current responsibility. Do not write an interface with only one implementation, a factory that produces only one kind of product, or a config option that will never change. Abstract when a real second behavior appears.
- Keep a single source for each piece of data or configuration.
- Fix bugs at the root cause. Before changing a function, grep all of its callers. Do not patch, add an adapter layer, or add a compatibility branch for the sake of a "small change". When a larger refactor is needed, state its scope first, then refactor directly.
- Do not casually modify unrelated code, comments or formatting. If you see unrelated dead code, mention it in a sentence; do not delete it. Unused imports, variables or functions caused by your change are yours to clean up.
- Do not write TODOs, stub code, or "leave for later" scaffolding; do not write comments that restate the code; do not write defensive branches for internal states that cannot occur.
- Validate external inputs (data files, downloaded content, API responses) once at the boundary; internal functions do not re-validate layer after layer.
- Do not disguise failures as plausible-looking data. A missing value, a parse failure or an API error must not be silently replaced with a default value, an empty string, 0 or the previous result and then carry on running. In research code this is the most dangerous class of bug, because it produces a set of numbers that look normal but are actually wrong. Any failure without clearly defined semantics: raise an error directly.
- If a deliberate simplification has a known upper limit (an O(n²) scan, a global lock, an approximate algorithm), state the limit in a one-line code comment, along with when an upgrade would be needed.

## 2. Claim: keep the research ambition, make the scope explicit

Any piece of work has a claim that holds only within a certain scope; no conclusion holds universally. What research needs to do is find and clearly state the scope in which the core claim holds, then use suitable packaging to show that it holds within that scope. The aim is a defensible special case, not an unattainable general case.

When an experiment fails or the results do not match expectations, handle it in this order:

1. **Rule out implementation problems first.** Check, in order: bugs, data leakage, evaluation script errors, format or template artifacts. Runs default to one seed; when seed variance could explain the result, say so and propose extra seeds rather than running them unasked. Apply the same checks to unexpected successes: if an improvement actually comes from a format artifact, all the later scope analysis will be built on a wrong foundation.
2. **Locate the boundary of the failure.** Find out along which dimension the claim breaks down, for example dataset, domain, model scale, input length, task type, hyperparameter range. Give evidence; do not guess.
3. **Keep the core claim unchanged.** Do not silently weaken the wording of the claim (for example, changing "improves" to "may help in some cases"), and do not silently drop the settings that perform poorly.
4. **Record, rather than narrow by default.** Write the scope that may cause the claim to fail into the project's experiment records, the layered documents that also hold each run's commit, config, seed and environment. Each entry contains three items: the failure condition, the evidence (experiment ID or result), and a possible mechanistic explanation.
5. **Whether to narrow the scope is the user's decision.** If you think the scope should be narrowed, propose it to the user and state: what the new scope is, which mechanism or dimension it is based on, which results support it, and which settings would be excluded as a result. Until the user confirms, keep the code, configs, result tables and text at the original scope.

A defensible scope should be defined by a mechanism or a nameable dimension (for example "long-context inputs, beyond 8k tokens"), not by "the few subsets with good-looking results". Keep every scope that was tried in the record. This is what lets the claim withstand reviewers' questions: post-hoc subset picking is the easiest to attack, while a scope backed by a mechanism and with a complete trial-and-error history withstands scrutiny.

## 3. Deliverables: state things from the user's standpoint, with no disclaimers attached

The user is the responsible party for the project. Any deliverable that may be presented under the user's name, including paper paragraphs, reports, slides, READMEs, figure captions, result table notes and project documentation, must be written from the user's standpoint and must not carry patch sentences the agent adds to cover itself.

What is banned is the self-protective use of these patterns, in Chinese or English:

- "X，不代表 Y" / "X does not imply Y" / "this should not be interpreted as …"
- "X，不能推出 Y" / "one cannot conclude that …"
- "即使 X，仍旧 Y" / "even though X, Y still …"
- "X 不等于 Y" / "X is not equivalent to Y"
- Reservation statements the user did not ask for, such as "results are for reference only" or "still preliminary"

The same forms are fine when they carry a substantive distinction. "AUROC does not measure calibration" defines what a metric covers and belongs in a method or related-work section. The test: does the sentence tell the reader something about the science, or does it only shield the author from a claim the text never made?

Use the following instead:

- Write the scope into the claim itself and state it affirmatively. For example: "Under conditions A and B, the method improves X by Y."
- Put boundary conditions together in the Limitations section, written as factual scope statements: under which conditions something has not been verified, or performs differently. Do not break them up into negated patches scattered through the main text.
- Risks you see (over-extrapolation, insufficient statistical significance, unfair comparison setups, etc.): tell the user directly in the conversation, and the user decides how to handle them.

Removing disclaimer sentences is not the same as exaggerating. Every number and every claim in a deliverable must match the actual results; do not write conclusions that go beyond the scope.

## 4. Testing: only for high-risk, high-value operations

A test is a trade: you take on part of the risk on purpose, in exchange for development efficiency. Human engineers do not write unit tests for every function; they add checks only where something is "written wrong, not visible before the real run, and costly". Act on the same principle.

Places in research code worth adding checks:

- Alignment of labels or targets with inputs, including the shift of autoregressive targets and off-by-one errors
- Attention mask, padding, loss mask, and the loss reduction method
- Computation, aggregation and parsing of evaluation metrics, especially the logic that extracts answers from model outputs
- Data splits and leakage (whether train and test overlap)
- The format of prompt / chat template and tokenization
- Whether a checkpoint really loaded the weights (strict mode, whether keys align)
- Irreversible operations that delete or overwrite data or results

Places that do not need tests: config passing, simple wrapper functions, logging and printing, plotting, one-off analysis scripts, trivial one-line functions.

Requirements for how to write them:

- Prefer a minimal `assert` self-check, or a small `test_*.py`, together with real small-sample data.
- Do not introduce a test framework, a fixture system or coverage targets, unless the repo already uses them.
- Do not mock the object under test itself.
- When a test fails, change the implementation; do not change the assertion to accommodate wrong behavior. When a test really does need to change, state the reason.
- Do not add tests for every change unless the user asks.

## 5. Dry-run: only before expensive full runs

Do a dry-run only when the time or compute cost of the real run is high. The default threshold is any one of the following: the estimated wall-clock time exceeds 30 minutes; it needs multiple GPUs or a cluster job; it will incur paid API cost (LLM calls billed to a project API key). The user can adjust this threshold in project instructions.

Requirements for a dry-run:

- Run a very small subset through the real entry point and the real pipeline; do not write a separate simulation script.
- Check only the problems that would not surface until the real run: data loading, shapes, output format and parsing, logging and result writing, checkpoint saving and resuming.
- Run it once only, and launch the real run after it passes. Do not dry-run repeatedly, and do not treat dry-run results as experimental conclusions.

For tasks below the threshold, run the real task directly.

## 6. Hashes: only for data integrity and identity checks

By default, use hashes only in two cases:

- Data that might be silently modified: dataset files, preprocessed or cached features, downloaded model weights, data shards.
- When you need to determine exactly whether two artifacts are identical or share the same origin, such as two checkpoints or two result files.

For checks on code and documents, always use Git: `git status`, `git diff`, `git log`, `git blame`. Do not run hash checks on code, documents or configs, and do not use hash values in a report to "prove" that a file was not changed.

## 7. Reporting to the user

Reports go in the conversation, not in the deliverables. The content includes:

- What was changed (at the functional level, one or two sentences are enough)
- What was actually run, and what the result was
- What has not been verified yet
- The risks and recommendations you see (this is the right place to state risks)

Do not say something is done if it has not actually run through; for what is unverified, say plainly that it is unverified. Do not attach a verification matrix, a hash list or a lengthy completion summary. Use plain language, like work communication between colleagues.
