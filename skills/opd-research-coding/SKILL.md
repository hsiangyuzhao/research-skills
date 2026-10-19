---
name: opd-research-coding
description: Use when writing, debugging, or designing experiments for on-policy distillation research code: OPD, on-policy self-distillation (OPSD) with privileged information, and OPD combined with RLVR (teacher signal plus verifier reward, e.g. positive-advantage gating). Covers teacher-student KL losses (reverse/forward KL, teacher or student top-k support), sampled-token log-ratio advantages, top-k overlap ratio, SFT warm-up before distillation, verl distillation recipes, thinking vs non-thinking teacher/student setups, and failures such as entropy spikes, garbled output, length inflation, repetition, "wait" flooding, or fast-rise-then-collapse curves.
---

# OPD Research Coding Assistant

Use this skill for research code involving on-policy distillation (OPD), on-policy self-distillation (OPSD), and OPD combined with RLVR: writing training code, modifying verl recipes, designing experiments, and diagnosing failed runs. The user writes code to do research, not to ship products.

## Core framing (apply when writing code and when interpreting results)

- OPD stabilizes rather than extends. It helps the student reliably sample correct paths that are already within its reach; it essentially does not raise the student's capability ceiling. Do not design OPD to teach a small model something it fundamentally cannot reach.
- OPD's effectiveness depends almost entirely on the quality of the teacher signal, not on teacher scale.

## Workflow

### 1. Before training: write diagnostic scripts before the training script

Before the user launches training, proactively provide or check the following diagnostics. Each should be a small runnable script or notebook cell.

1. **Student rollout quality**: sample N rollouts and report the valid-format rate, mean length, and truncation rate. If rollouts are not well-formed, do an SFT warm-up first, on teacher-compatible chain-of-thought (CoT) data (incorrect rollouts also work), using LoRA trained to near saturation.
2. **Top-k overlap ratio**: on student-visited states, compute |TopK_S ∩ TopK_T| / k and average it. If it is low, switch to a same-family teacher, apply teacher-aligned prompt selection (keep only prompts the teacher covers well), or first compare against Semi-OPD (distilling on offline rollouts from the initial student).
3. **Teacher error-correction test**: construct or collect erroneous student prefixes and check whether the teacher's probability mass moves toward a corrective branch, or only toward tokens such as "wait", "maybe", or "actually" that read fluently locally but in substance continue down the wrong path. If the teacher fails to correct most erroneous prefixes, recommend a different approach.
4. **Vocabulary check**: confirm whether teacher and student share a tokenizer. If not, align them via decode → teacher chat template → re-encode, and verify that the round trip is lossless at the splice point.
5. **Teacher generation budget**: confirm that the teacher's max_tokens covers the middle and later parts of the student's reasoning chain. If teacher generations nearly fill the budget, the supervision covers only a small segment of the reasoning chain.

### 2. Implementation rules

- **Make the support set explicit**: taking student log-probs over the teacher's top-K (teacher support) and over the student's own top-K (student support) correspond to different KL directions and different gradient properties. State which one is used in code and comments; do not mix them.
- **Sampled-token advantage**: the standard form is A_t = log π_T(y_t | c_t) − log π_θ(y_t | c_t), with y ~ π_θ. It has high variance and provides essentially no useful signal in the zero-advantage and negative-advantage regions.
- **Non-positive-advantage regions**: prefer replacing the update there with a forward KL term on the teacher's top-K support (renormalize within the support before computing it). This tells the student where to move probability mass, instead of only pushing the sampled token down (Asymmetric OPD).
- **Variance reduction**: optionally add a control-variate baseline (the vOPD approach), or replace the single-sample signal with a top-K distribution-level KL.
- **Coupling with RLVR** (preferred when a verifier exists): apply the teacher-based reweighting only to responses whose outcome advantage is positive; for responses with negative advantage, fall back to the plain RL objective (Distilled RL; the gate is per response).
- **Memory**: do not compute log_softmax over the full vocabulary in one pass; the backward pass materializes a tensor of shape [B, T, V]. Compute in chunks along the token dimension (recent verl versions expose a chunk_size parameter). Top-k can be taken directly on raw logits because softmax is monotonic, but the logsumexp still has to cover the full vocabulary.
- **Sampling consistency**: do not add a repetition penalty or change the sampling temperature at rollout time to suppress symptoms. Doing so makes rollouts deviate from π_θ and introduces uncorrected off-policy bias.
- **A coefficient schedule is standard practice**: ramp the OPD/OPSD coefficient up linearly, optionally ending the warm-up early once the KL has dropped substantially; then anneal it linearly so that the RL objective gradually takes over. Save checkpoints and support early stopping.
- **Long sequences**: consider position weighting, prefix-gated losses, distilling only on prefixes, and terminating a rollout early once the teacher-student KL stays persistently low, i.e. the teacher agrees with a degraded state and gives little corrective signal (the KAT approach). For multi-turn agent tasks, use the ground truth of the first n turns as context and train only on turn n+1, or sample early prefixes with higher weight.
- **Framework**: default to verl ≥ 0.8 and its official async on-policy distillation recipe. Its one-step and two-step off-policy schedulers mitigate the low GPU utilization caused by the teacher and student idling in turn.

### 3. Metrics that must be logged (remind the user if any is missing)

- overlap_ratio (verl provides distillation/overlap_ratio and distillation/overlap_token_advantage)
- Mean response length and truncation rate (the warning sign is length growing while the truncation rate rises, not the direction of length change by itself)
- Policy entropy (it should not change sharply: a spike points to probability leakage from negative advantages, a sharp drop to entropy collapse)
- Repetition rate, and the frequency of filler tokens such as "wait", "maybe", and "actually"
- Fractions of per-token advantages that are positive, negative, and zero
- Mean and variance of the advantage, bucketed by token position
- Task metrics: report pass@1, avg@k, and pass@k together

### 4. Symptom → cause → remedy

| Symptom | Likely cause | First-line remedy |
| --- | --- | --- |
| Overlap ratio stalls within the first few dozen steps | Teacher and student are incompatible | Same-family teacher / prompt selection / Semi-OPD |
| Garbled output, entropy spikes | Probability mass from negative advantages leaks into the tail | Forward KL on the teacher's support; check whether only reverse KL is used |
| Sudden length inflation; truncated rollouts dominate the data | Length inflation | Reference-policy divergence constraint + rollout mixture (mix in complete reference trajectories) |
| Degenerate repetition | Repeated tokens receive inflated positive advantages, which self-reinforce | Reference KL, length control, early termination |
| "wait" floods the thinking block | Poor prefixes lead the teacher to reasonably reward self-correction markers; the student learns only the markers | Prefix gating / early termination; interleaved SFT during distillation (unverified) |
| Fast early gains followed by collapse | Over-reliance on the self-distillation signal | Positive-advantage gating + coefficient annealing + early stopping |
| pass@k rises while pass@1 and avg@k fall | Variance increased; the capability boundary did not move | Check supervision coverage (teacher budget, truncation) |
| Advantage variance explodes in the second half of sequences | Long-horizon drift | Position weighting / prefix-only distillation |

Identify the cause before proposing a remedy. A flood of "wait" tokens has at least three distinct causes (myopia of the per-token objective, probability leakage from negative advantages, and inflated positive advantages on repeated tokens), and their remedies do not substitute for one another.

### 5. Experiment design rules (check when writing experiment configs or papers)

- The mainstream OPSD thinking configuration is teacher on, student off.
- **Cross-mode transfer**: the gain from a non-thinking student with a thinking teacher may come from cross-mode transfer. When a result attributes a gain to privileged information, propose these three controls to the user:
  1. Plain OPD without privileged information;
  2. A teacher given unrelated context of matched length (for example, a solution to a different problem, or unrelated audio);
  3. A configuration in which teacher and student use the same thinking mode.
- To isolate the distillation gain itself, all rollouts can be forced into non-thinking mode.
- When the student is itself a thinking model, privileged self-distillation can suppress forking and deliberative behavior and degrade performance.
- Runs default to one seed. Before claiming greater stability, propose at least 3 seeds to the user. Run curves until clear saturation or collapse; do not truncate near the peak and then claim greater stability.
- When a verifier exists, include pure RLVR as a baseline. Pure OPSD without an external reward often decays quickly.

## References (read on demand; do not load all at once)

This file holds only the operating rules. Specific numbers, paper links, and full arguments live in `references/`:

| File | Contents | When to read |
| --- | --- | --- |
| `references/knowledge-base.md` | Full version of the four-layer framework plus the cross-cutting thinking-mode section: mechanism, remedy, evidence figures, and paper links for each failure mode; pre-training checklist and monitoring table | When citing evidence or effect sizes; checking whether an idea has already been done; writing related work or experimental-design rationale; when the user asks "why" |
| `references/case-study-opsd-rlvr.md` | Nine-run OPSD+RLVR replication (positive-advantage gating, top-k, temperature, type of privileged information, rlsd_lambda): peaks, collapse timing, and limitations | When designing OPD+RLVR experiments or hyperparameters; diagnosing "fast early gains, then collapse" |
| `references/community-claims.md` | Credibility assessment of eight community claims from a discussion about "wait" flooding | When the user cites community experience or online advice; check here first |
| `references/bibliography.md` | Papers and code, grouped by topic | When a source is needed or the original text must be checked |

## Evidence levels

Distinguish sources when citing experience:

- **Supported by papers**: Rethinking OPD, CUHK's Demystifying OPD, Simple-OPD, Semi-OPD (NVIDIA), Revisiting OPD, Stable-OPD, KAT, SAF-OPD, Asymmetric OPD, Distilled RL, and the OPSD cross-mode transfer papers.
- **Community experience, unverified**: for example, "the teacher's key metric must exceed 95%" and "effective OPD should make trajectories shorter over training". Treat these as hints only, never as rules.

When the user proposes a new OPD method or diagnosis, first locate which layer of the four-layer framework in `references/knowledge-base.md` it acts on (prerequisites / estimator and objective / training dynamics / engineering), then discuss it.
