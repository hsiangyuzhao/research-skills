# Credibility Assessment of Community Claims ("wait" flooding thread)

Source: a Xiaohongshu (RedNote) help thread. With verl's policy-gradient OPD and thinking enabled, trajectories grew longer after distillation and the thinking block filled up with "wait", "maybe", and similar tokens; the claims below come from the replies. The phenomenon itself is credible and consistent with the length-inflation and repetition mechanisms in Layer 3 of the knowledge base. The explanations vary widely in credibility.

| Claim | Credibility | Reasoning |
| --- | --- | --- |
| Poor student trajectories → the teacher leans toward reflection and correction → the student grows longer the more it learns | High | Consistent with the myopic-objective mechanism: the teacher reasonably rewards "wait", and the student learns only the marker. The thread author says they found a fix but has not published it |
| Policy-gradient OPD only pushes tokens down without saying where to go; use forward KL on these tokens | High, but incomplete | Consistent with Asymmetric OPD. However, repeated tokens receive inflated positive advantages, which forward KL does not address; the author added clipping and a top-k support set and still did not fully fix it |
| Add a reference-policy KL to keep the student from drifting too far | High | One of the mechanisms in Stable-OPD |
| Soft overlong punishment | Medium | The DAPO approach; usable as symptomatic treatment. Pure OPD needs an extra reward term for it |
| Add a repetition penalty during sampling | Low | Breaks on-policy consistency and only masks the symptom; "wait" flooding is not necessarily verbatim repetition |
| Penalties make probability mass leak and entropy rise | Mechanism correct, not applicable here | The author observed no large rise in entropy. The claim also conflates the mode-seeking property of reverse KL with leakage caused by single-sample gradients |
| A strong teacher encourages long chains of thought, so the student only learns transition words | Phenomenon correct, attribution off | The issue is per-token myopia, not teacher strength. The author's citation of fork suppression in support is a misreading: that paper finds forking decreases |
| Effective OPD should make trajectories shorter over training | Low | Overgeneralized; watch the truncation rate rather than the direction of length change |
