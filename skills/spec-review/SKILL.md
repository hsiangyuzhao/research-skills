---
name: spec-review
description: "Check that the changes since a fixed point do what the paper's method section, experiment plan, proposal or issue says: data splits, preprocessing, model and training settings, metric computation."
disable-model-invocation: true
---

Review the diff between `HEAD` and a fixed point the user supplies against its **spec**: what the code was written to do, whether that is the method a paper describes, an experiment plan, a proposal or an issue. This catches the gap between what the paper says was done and what the code does, which matters most before releasing research code or submitting.

Repo conventions, code smells and general bugs are out of scope: the built-in `/code-review` and `/simplify` cover them.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Confirm it resolves (`git rev-parse <fixed-point>`) and that `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base) is non-empty. A bad ref or an empty diff stops the review here. Note the commit list with `git log <fixed-point>..HEAD --oneline`. The three-dot diff covers commits only; if the working tree has uncommitted changes, ask whether to include them, and if so review `git diff <fixed-point>` instead.

### 2. Identify the spec

Look for what the code was meant to do, in this order:

1. A path or text the user passed as an argument.
2. A method description in the repo: a paper draft (LaTeX method or experiments section), a proposal, or an experiment plan under `docs/`, `paper/`, `notes/` or similar, matching the branch or feature.
3. Issue references in the commit messages (`#123`, `Closes #45`), fetched with the tracker's CLI when one is available.
4. If nothing is found, ask the user where it is. If there is none, stop: this review has nothing to check against.

### 3. Review

Run the review in a sub-agent so the diff and the spec do not crowd this conversation. Give it the diff command, the commit list, the path or fetched contents of the spec, and this brief:

"Report: (a) requirements the spec asks for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong; (d) where the spec is a method or experiment description, any mismatch in data splits, preprocessing, model or training settings, or how metrics are computed. Quote the spec line and the code location for each finding. Under 400 words."

### 4. Report

Present the findings grouped under (a) to (d), each with its spec quote and code location. End with one line: the number of findings and the one most likely to change a reported result, if any.
