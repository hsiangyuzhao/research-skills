# OPD Knowledge Base: Four-Layer Failure Modes, Diagnostics, and Remedies (with figures and links)

Compiled 2026-10-19. Sources: 2026 OPD/OPSD papers and community practice posts.

## TL;DR

OPD is a tool for stabilizing sampling, not for raising the capability ceiling. It helps the student reach correct paths within its own capability faster and more reliably; expecting it to make a 7B model learn what only a 70B model can do will almost always disappoint. This knowledge base integrates six community posts and discussions with about 20 papers from 2026, organized in four layers: prerequisites → estimator and objective → training dynamics → engineering and systems. The thinking-mode configuration is treated separately as a cross-cutting issue.

The five most important points:

1. **Measure overlap before you train.** Teacher-student top-k overlap is the leading predictor of whether OPD succeeds. If overlap is low, switch to a same-family teacher, apply teacher-aligned prompt selection, or switch to offline student rollouts altogether (Semi-OPD).
2. **Do not skip the warm-up.** SFT warm-up transfers a teacher-compatible thinking pattern, not correct answers; LoRA trained to near saturation works better.
3. **The sampled-token signal essentially fails in non-positive-advantage regions.** For negative and zero advantages, either use a forward KL on the teacher's support or fall back to the RL advantage.
4. **The OPD/OPSD signal must decay over training.** In the replication case study, every OPSD+RLVR variant rose fast and then collapsed. Coefficient annealing, positive-advantage gating, and early stopping are standard practice.
5. **The gain from "non-thinking student, thinking teacher" is confounded.** A substantial share comes from cross-mode transfer rather than from privileged information or a stronger teacher; propose controls to the user when designing such experiments.

## Layer 1: Prerequisites

Most OPD failures are determined before training starts. This layer decides whether to do OPD at all, and with which teacher.

| Prerequisite | Failure symptom | Diagnostic | Remedy | Evidence |
| --- | --- | --- | --- | --- |
| Student can generate well-formed trajectories | Applying OPD directly to a base model; the teacher's logits on garbage prefixes are noise | Inspect initial rollout quality and truncation rate | SFT warm-up (off-policy cold start) on teacher-compatible CoT; incorrect rollouts also work; LoRA trained to near saturation | [Rethinking OPD](https://arxiv.org/abs/2604.13016v2), [Simple-OPD](https://arxiv.org/abs/2608.06802v1) |
| Compatible teacher-student thinking patterns | A large teacher does worse than a small one; per-token rewards point in inconsistent directions and cancel when aggregated | Top-k overlap ratio; in successful runs it rises steadily, in failed runs it stalls from the start | Same-family teacher; teacher-aligned prompt selection; apply the loss only in the overlap region | [Rethinking OPD](https://arxiv.org/abs/2604.13016v2) |
| Teacher offers new capability | A same-family, similar teacher scores higher yet provides no driving signal | Weak-to-strong reverse distillation test | Use a teacher that genuinely has the new capability (e.g., a domain-RL-trained version) | [Rethinking OPD](https://arxiv.org/abs/2604.13016v2) |
| Whether on-policy sampling is actually needed | With low overlap, OPD loses to offline methods | Initial output-token overlap | Low overlap → Semi-OPD (offline rollouts from the initial student); it won in 14 of 17 teacher-student pairs | [NVIDIA Semi-OPD](https://arxiv.org/abs/2610.11291v1) |
| Vocabulary | Token-level KL cannot be computed directly across vocabularies | n/a | A shared vocabulary is easiest; across vocabularies, use decode → teacher template → re-encode, or cross-tokenizer OPD | [EasyOPD](https://arxiv.org/abs/2607.11012v1), [ROSE implementation](https://huggingface.co/SeanWang0027/rose-opd-implementation) |
| Teacher can correct the student's errors | On erroneous prefixes the teacher only offers tokens such as wait/maybe that are locally fluent but in substance continue the wrong path | Construct erroneous prefixes and check whether probability mass moves toward a corrective branch | Mild cases: prefix gating, dynamic truncation (KAT); if most erroneous prefixes go uncorrected → change approach | Community posts, [KAT](https://arxiv.org/abs/2606.09471v1) |
| Verifier availability | Without a verifier you can only trust the teacher, leaving little margin for error | n/a | With a verifier → prefer RLVR / filtered OPD / OPD+RLVR; without → closely monitor drift and teacher feedback quality | Community posts |

**Questionable rule of thumb:** "the teacher's key metric on the target task must exceed 95%" comes from a community post; no source was found. Current evidence emphasizes teacher-student alignment over the teacher's absolute score.

## Layer 2: Estimator and objective

Standard OPD is a policy gradient that uses the per-token log-ratio as the advantage. Its problems come mainly from single-sample estimation and from the non-positive-advantage regions.

```latex
A_t = \log \pi_T(y_t \mid c_t) - \log \pi_\theta(y_t \mid c_t), \quad y \sim \pi_\theta
```

| Problem | Mechanism | Remedy | Evidence |
| --- | --- | --- | --- |
| Fragile sampled-token signal | Distribution matching is reduced to a single-token signal; it becomes increasingly unreliable once prefixes drift away from regions the teacher commonly visits | Compare next-token distributions over the teacher's top-K (a distribution-level signal); reported +19.8% over the sampled-token baseline | [Revisiting OPD](https://arxiv.org/abs/2603.25562v2) |
| High single-sample variance | Single-sample Monte Carlo estimate | vOPD: add a control-variate baseline (a value function), approximated with top-k to reduce cost | [KL for a KL](https://arxiv.org/abs/2605.07865v1) |
| No signal in zero-advantage regions | When teacher and student agree on the sampled token, that position has no gradient, and the teacher's preferences over other tokens are discarded; most tokens sit near zero advantage | In non-positive regions, use a forward KL on the teacher's support | [Asymmetric OPD](https://arxiv.org/abs/2605.06387v4) |
| Negative advantages only push down, never pull toward | Wrong tokens are suppressed without indicating the correct alternative; probability mass leaks into tail noise → entropy spikes or garbled output; worse for weak students | As above: forward KL supplies the "where to go" direction; or fall back to the RL advantage when the advantage is negative | [Asymmetric OPD](https://arxiv.org/abs/2605.06387v4); vocabulary routing in the [formula-driven survey](https://arxiv.org/abs/2606.22793v1) |
| Imbalanced positive and negative rewards | Most sampled tokens receive negative reward, so optimization is dominated by a few positively rewarded tokens (fillers, short continuations) | Positive-advantage gating; sequence-level geometric normalization | [Distilled RL](https://arxiv.org/abs/2607.17247v2) |
| Pure imitation converges prematurely | KL imitation quickly aligns visited states but lacks a task-aware signal; performance saturates early or even declines | Couple with RL: the teacher gives fine-grained guidance only when the sampled response is beneficial (Distilled RL: reweight positive advantages, fall back to the RL objective for negative ones; RLSD: the teacher signal reweights reward-driven updates) | [Distilled RL](https://arxiv.org/abs/2607.17247v2), [On Repulsive and Attractive Teachers (RLSD and related work)](https://arxiv.org/abs/2609.21561v1) |

**Two implementation details:**

- **Make the choice of support set explicit.** Taking student log-probs over the teacher's top-K set (teacher support) and over the student's own top-K (student support) correspond to different KL directions and gradient properties; do not mix them in code.
- **Reverse and forward KL are complementary.** Reverse KL (mode-seeking) drives policy improvement on student-sampled states; forward KL supplies the "where to go" direction at negative- and zero-advantage positions. Policy-gradient OPD that uses only reverse KL is more prone to probability leakage.

## Layer 3: Training dynamics

Even with the first two layers right, OPD can degrade partway through training. The three most common forms are runaway length, long-horizon drift, and premature saturation or collapse.

### Length inflation and repetition

Rollout length can inflate abruptly, so that truncated trajectories dominate the training data ([Stable-OPD](https://arxiv.org/abs/2604.08527v1)). Repeated tokens receive systematically larger reverse-KL advantages; once repetition starts it self-reinforces, and the student is effectively hacking the teacher's likelihood signal. Stable-OPD's remedy is a reference-based divergence constraint plus rollout mixture (mixing in reference trajectories to maintain the fraction of complete trajectories), improving mean accuracy by 7.2% over standard OPD.

### Flooding with filler tokens (wait/maybe): separate the three causes

| Cause | Mechanism | Remedy |
| --- | --- | --- |
| Myopic objective (most important) | On erroneous prefixes the teacher reasonably assigns "wait" high probability; the per-token objective rewards only the marker and does not guarantee that a real correction follows, so the student learns the posture of self-correction | Prefix gating, KAT-style early termination; interleaved SFT during distillation (community suggestion, unverified) |
| Probability leakage from negative advantages | Sampled-token updates push down the penalized token and spread its mass over other candidates | Forward KL / teacher support (see Layer 2) |
| Inflated positive advantages on repeated tokens | On repetitive prefixes the teacher also assigns high probability to continuing the repetition | Reference KL, length control (soft overlong punishment), rollout mixture |

Adding a repetition penalty at sampling time is not recommended: it makes rollouts deviate from π_θ, introduces additional off-policy bias, and only masks the symptom.

### Long-horizon drift

Once the prefix has drifted in the second half of a sequence, the quality of teacher feedback drops quickly, and the second half is essentially fed noise. Short tasks are barely affected.

- Position weighting, Prune-OPD, prefix-gated OPD, and trust-region constraints (see the [Simple-OPD reference list](https://arxiv.org/abs/2608.06802v1)).
- Distilling only on prefixes: prefix OPD comes close to full OPD at lower cost ([Fast and Effective On-policy Distillation from Reasoning Prefixes](https://arxiv.org/abs/2602.15260v1)).
- Multi-turn agents: use the ground truth of the first n turns as context and train only on turn n+1; or use ReOPD's step-decayed prefix sampling, which emphasizes early, low-drift prefixes ([ReOPD](https://arxiv.org/abs/2607.04763v3)).
- KAT terminates a rollout once persistent low-KL agreement is detected (the teacher agrees with a degraded state, so the signal carries little correction), cutting mean rollout length from 1480 to 596 tokens while improving avg@k by 2.66% relative (30.27 to 31.08, averaged over AMC, MATH500, MinervaMath and AIME24 and two student sizes) ([KAT](https://arxiv.org/abs/2606.09471v1)).

### Premature saturation and collapse

OPD improves quickly early on, then saturates or even declines; when mixed with RLVR it is more likely to collapse outright (see the case study). The OPD/OPSD signal should decay over training. SAF-OPD ramps up linearly, ends the warm-up early once the KL drops, and then anneals linearly so that GRPO takes over ([SAF-OPD](https://arxiv.org/abs/2607.29209v1)). In practice: start annealing near the peak or switch back to pure RLVR, combined with checkpoint-based early stopping.

### Diagnosing length correctly

"Effective OPD should make trajectories shorter over training" does not hold; the direction of length change depends on the student's initial length and the teacher's length. The warning sign is "longer and with a rising truncation rate". In thinking mode, OPD only retains stopping behavior the student already has and does not teach new stopping, so smaller students are more likely to be unable to stop ([Solving Without Stopping](https://arxiv.org/abs/2609.37326v1)).

## Layer 4: Engineering and systems

Prefer verl: community posts report that training on ms-swift kept going wrong and only worked after moving to verl, and verl ships an official OPD recipe and diagnostic metrics.

| Pitfall | Cause | Fix |
| --- | --- | --- |
| Low GPU utilization | Teacher and student deployed separately and idle in turn | The one-step/two-step off-policy schedulers in verl's async on-policy distillation recipe overlap generation, teacher queries, and updates, trading a small amount of off-policyness for throughput ([verl docs](https://verl.readthedocs.io/en/latest/advance/async-on-policy-distill.html)) |
| OOM when increasing batch size or token length | Older verl (0.5.0.dev0) computes log_softmax over the full vocabulary, and the backward pass materializes a [B, T, V] tensor | Upgrade verl and set chunk_size for chunked, streaming computation; top-k can be taken on raw logits (softmax is monotonic), but the per-position logsumexp still covers V |
| Supervision covers only a small segment of the reasoning chain | Teacher max_tokens too small; almost every generation exhausts the budget | Check the teacher's generated length as a fraction of its budget; in this case supervision covered only about 6% of the student's reasoning chain ([ROSE log](https://huggingface.co/SeanWang0027/rose-opd-implementation)) |
| No built-in overlap monitoring | n/a | verl logs distillation/overlap_ratio and distillation/overlap_token_advantage ([verl/trainer/distillation/losses.py](https://github.com/volcengine/verl/blob/main/verl/trainer/distillation/losses.py)) |
| verl version pitfall | In-training validation has problems in v0.7.0 | Set trainer.test_freq=-1 and evaluate offline, or upgrade to v0.8.0 (same source) |

## Cross-cutting: thinking-mode configuration

"Non-thinking student, thinking teacher" is the mainstream OPSD configuration and it does work, but a substantial share of the gain comes from cross-mode transfer, i.e., compressing the teacher's thinking behavior into the student's direct answers, rather than from privileged information or a stronger teacher.

| Finding | Evidence |
| --- | --- |
| With thinking enabled on both sides, Qwen3-1.7B AIME 2024 Avg@12 is 49.24, 6.18 points below the asymmetric configuration and slightly below the base model (single seed) | [Privileged Solutions or Context-Induced Teacher Behavior?](https://arxiv.org/abs/2608.09228v1) |
| Replacing the privileged reference with the solution to a different problem (OP²SD) still beats the base model and is competitive with OPSD | Same as above |
| When a thinking teacher supervises direct-response rollouts, reference-free distillation accounts for most of the improvement; switching to long thinking-enabled rollouts turns gains into losses | [What Does Privileged Information Add to OPSD?](https://arxiv.org/abs/2609.20612v2) |
| Privileged self-distillation causes up to a 17% relative drop in avg@16 for thinking models, by suppressing forking and deliberative behavior (fork suppression) | [Rethinking OPSD for Thinking Models](https://arxiv.org/abs/2607.05184v1) |
| Rigorous studies force all rollouts into non-thinking mode to separate genuine distillation gains from thinking-mode shifts | [Demystifying OPD (CUHK)](https://arxiv.org/abs/2607.13399v1) |

**Implications for experiment design:** when an experiment claims that privileged information helps, propose to the user three controls: plain OPD without privileged information, a teacher given unrelated context of matched length, and a configuration in which teacher and student use the same thinking mode.

## Pre-training checklist and monitoring

### Before training

- [ ] Initial student rollouts are well-formed with a low truncation rate; otherwise do an SFT warm-up first (teacher-compatible CoT, LoRA)
- [ ] Measure the initial top-k overlap ratio; if low → same-family teacher / teacher-aligned prompt selection / compare against Semi-OPD first
- [ ] Construct erroneous prefixes and confirm the teacher corrects them rather than continuing along them
- [ ] Confirm the vocabularies match, or that cross-vocabulary alignment is implemented
- [ ] Teacher max_tokens is large enough to cover the middle and later parts of the student's reasoning chain
- [ ] Decide whether a verifier is available; if so → plan OPD+RLVR with positive-advantage gating
- [ ] Fix the teacher and student thinking-mode configuration, and decide with the user whether to run the three controls (no privileged information, unrelated context, symmetric modes)
- [ ] Fix the support set (teacher top-K or student top-K) and the KL direction; do not mix them in code
- [ ] Implement OPD coefficient annealing and a checkpoint-based early-stopping policy
- [ ] verl ≥ 0.8, with chunked log-prob computation enabled

### Must-watch during training

| Metric | What to look for | Warning sign |
| --- | --- | --- |
| overlap_ratio | Should rise steadily | Stalls in the first few dozen steps → training will get stuck |
| Mean length, truncation rate | The direction of length change depends on the task | Longer and with a rising truncation rate |
| Entropy | Should not change sharply | Spikes → probability leakage from negative advantages; collapses → entropy collapse |
| Repetition rate, filler-token frequency (wait/maybe) | Should stay flat | Keeps rising → reward hacking |
| Per-token advantage distribution (positive/negative/zero fractions) | Shows where the signal is concentrated | Optimization dominated by a few positive-advantage filler tokens |
| Task metrics (pass@1, avg@k) | Read together with pass@k | pass@k up while avg@k and pass@1 go down → only variance increased |
| Advantage by position | Signal quality in the second half | Variance explodes in the second half → drift; needs down-weighting or truncation |
