# Case Study: Nine OPSD+RLVR Runs

Conclusion: every variant that adds a self-distillation signal follows the pattern "faster early, collapse later"; only pure RLVR rises steadily. Positive-advantage gating lifts the peak to about 88% and delays the collapse, but does not eliminate it. Source: a Xiaohongshu (RedNote) post, "OPD+RLVR: replication comparison (part 4)" (2026-09-25), which replicates a combination of Distilled RL and KL for a KL.

Values below are read off the plot and are approximate. The metric is win rate.

| Run | Configuration | Peak (approx.) | Step of peak | Afterwards |
| --- | --- | --- | --- | --- |
| BASE | Pure RLVR | 60% | 200 | Rises steadily |
| EXP8 | No reference answer + baseline + top-50 + T=2.0 + positive-advantage gating | 88% | 110 | Holds until about step 140, then falls to about 11% |
| EXP5 | Hindsight-feedback PI + positive-advantage gating | 70% | 90 | Curve ends; unknown |
| EXP7 | No reference answer + baseline + top-50 + T=2.0 | 66% | 80 | Falls to about 18% |
| EXP3 | No reference answer + rlsd_lambda=1.0 | 65% | 70 | Falls to about 22% |
| EXP1 | No reference answer | 64% | 90 | Curve ends; unknown |
| EXP2 | With reference answer | 52% | 60 | Declines to about 36% |
| EXP4 | Hindsight-feedback PI | 46% | 60 | Drops sharply to about 14% |
| EXP6 | No reference answer + baseline + top-20 + T=1.0 | 44% | 40 | Declines to about 20% |
| EXP9 | Pure OPSD, no external reward | 33% | 20 | Decays steadily to below 10% |

**Patterns that can be read off:**

- Positive-advantage gating helps (EXP8 beats EXP7; EXP5 beats EXP4).
- Pure OPSD without a verifier is essentially ineffective (EXP9).
- Adding the reference answer to the PI does not help (EXP2 is below EXP1), consistent with the cross-mode transfer findings in the thinking-mode section of the knowledge base.
- The larger the self-distillation weight, the faster the rise and the steeper the collapse (EXP3).
- top-50 + T=2.0 beats top-20 + T=1.0 (EXP7 vs EXP6).

**Limitations:** the win-rate opponent and judging method are not stated; each run appears to use a single seed; the EXP1 and EXP5 curves end at step 90, so they cannot be counted as "more stable"; there are no length, entropy, or repetition-rate curves, so it is impossible to tell whether the collapse is length inflation, repetition, or entropy collapse.
