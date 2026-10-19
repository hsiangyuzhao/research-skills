---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea, such as an experiment design, a paper's framing, a proposal or a rebuttal. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer; for a multiple-choice question, name the recommended option.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

While working the tree:

- **Pin down terms.** When the user uses a vague or overloaded term (sample, subject or scan; accuracy or balanced accuracy), propose the precise one and get it confirmed before building on it.
- **Check claims against the code.** When the user states how something works, check whether the code agrees, and surface any contradiction.
- **Cover the evaluation protocol.** For an experiment design, the tree must include: the level at which data is split (sample or subject), how the label or outcome is defined, which samples are excluded and why, the canonical coordinate frame or resolution, and how the metric handles edge cases. These decisions are hard to reverse, and they are what a methods section and a reviewer will ask about.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
