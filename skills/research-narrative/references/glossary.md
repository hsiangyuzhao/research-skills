# Glossary

The user's Chinese terms are the reference. Use them when conversing in Chinese, and use the English terms in English documents. Terms the user keeps in English (claim, research gap, contribution, motivation) stay in English in both.

| English | 中文 | Meaning in research work |
|---|---|---|
| Funnel narrative | 漏斗式叙事 | The order a paper argues in: background, a concrete research question, its motivation, the research gap, the contribution that answers the gap, and the experiments that support it. Engineering work is meaningful only as a step inside it. |
| Macro frame | 宏观框架 | The background, the broad problem and its negative constraints. It defines what the project is about and what it excludes. It rarely changes, and only the user changes it, usually by clarifying its boundary (for example, splitting a related line into a separate study). |
| Micro story | 微观叙事 | One concrete research question with its own motivation, gap, contribution and experiments. A small change in it gives a different paper. Expected to change during a project. |
| Micro hypothesis | 微观假设 | The hypothesis at the head of a micro story, e.g. "training on contexts where the relevant passage is marked teaches a model to find it when it is not marked". |
| Instance | 具体实现 | A concrete realisation of the macro frame: the model, the training method, the data, the evaluation. Changing the instance changes the micro story, not the macro frame. |
| Negative constraint | 负约束 | A condition the macro frame excludes, checkable on a result, e.g. "gains must not come from the answer leaking into the prompt". A result whose gain comes through such leakage crosses it. |
| Separability | 可拆分性 | Whether a route can, in principle, separate the effect the macro frame cares about from its obvious alternative explanations (model size, leaked answers, more training data). A route without it can pass every local test and still answer nothing at the macro level. |
| Claim | claim | The statement the work asserts, within an explicit scope. Kept unchanged until the user confirms a new one; narrowing is the user's decision. |
| Research gap | research gap / gap | What existing work does not answer and this work does. |
| Contribution | contribution | What this work adds that fills the gap; it is what the experiments must support. |
| Motivation | motivation | Why the gap matters, for the field or for practice. |
| Forward derivation | 正向推导 | Going from a micro hypothesis to its gap, contribution and the experiment that tests it, before running it. |
| Reverse look-back | 反向回看 | Going from experimental results back to the gap and contribution that explain them, and setting the paper's narrative accordingly. Normal research practice at the micro level; the agent proposes, the user decides, every result stays reported. |
| Turn | 转变 | Replacing the current micro story with another inside the same macro frame, by the user's idea or in response to results. Known to the user and stated. |
| Pivot (real research pivot) | 真实转向 | A turn forced by a finding that undermines a premise of the current micro story. Needs the user's decision; it must not be pulled back to the old plan as if it were drift. |
| Drift | 漂移 | Work that continues without a link to a confirmed micro story: a local optimum in engineering, data quality or significance, a story only the agent wrote, or a route without separability. Each step is usually approved, which is why neither side notices. |
| Reasonable deepening | 合理深入 | Detailed work (diagnostics, data, systems) that tests or strengthens a micro story the user has confirmed. Not to be interrupted. |
| Local / global | 局部 / 全局 | Micro-level choices (which results lead the paper, how a micro story is positioned) versus the macro frame. Local choices may follow the evidence; the global level must not move without the user. |
| Narrative anchor | 叙事锚点 | The project's NARRATIVE.md: macro frame, current micro story, earlier micro stories. Owned by the user; points to experiment records instead of copying them. |
| Look-back | 回看 | A short return of the conversation to the gap level: which part of the story the work serves, or that the link is missing. |
| Decision point | 决策点 | A moment where the agent asks the user to decide: a choice dialog, an approval, a budget, a rerun. Each carries one line naming the part of the micro story it serves. |
| Story debt | 叙事欠账 | Events since the last forward or reverse act that should have triggered one: a turn without a written micro story, or a story-moving result without a look-back. Drift is story debt accumulating while each step looks reasonable. |
| Return | 回归 | Resuming a project after a pause. The returning user hears the story first (macro frame, micro stories tried, current story), then the engineering state. |
