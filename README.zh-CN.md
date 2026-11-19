# Research Skills

[English](./README.md) | 简体中文

面向用编码 agent 做科研的常驻规则与 agent skill，适用于研究大语言模型及其下游应用的研究者。每个 skill 是 [`skills/`](./skills) 下的一个文件夹，内含一份 `SKILL.md`，采用 Claude Code、Codex 等工具都能读取的 Agent Skills 格式。部分通用 skill 改编自 [mattpocock/skills](https://github.com/mattpocock/skills)（v1.3.1，提交 `f3fc563`），并针对科研代码而非产品工程做了改造。

## 我们如何与编码 agent 一起做科研

**角色。** 研究者拥有项目，做出所有科学决策，是最终署名作者。agent 用必要且充分的工程实现研究者的核心想法，验证它，并把结果包装成一个经得起推敲的 claim。

**三个层次。** 科研工作分三层，每一层只有放在上一层里才有意义：

1. **叙事。** 论文论证所遵循的漏斗：背景、具体的研究问题、它的 motivation、research gap，以及回应 gap 的 contribution。它有两个层面。
   - **宏观框架**：背景、宏观问题和它的负约束（工作不能依赖什么）。很少变化，只由研究者改变。
   - **微观叙事**：一个具体的假设，带有它自己的 motivation、gap、contribution 和实验。假设的细小变化就会得到另一篇论文，所以微观叙事预期会变化。
2. **Claim。** 工作所主张的内容，始终在明确的范围之内：一个由机制或可命名的维度界定的、站得住的特例，而不是一个达不到的一般情形。
3. **工程。** 代码、实验、数据、作业和记录。不服务于任何 claim 的正确工程是浪费；服务于一个没人需要的 claim 的正确工程，就是漂移。

**两个方向。** 在微观层面，motivation、gap、contribution 和实验不是单向的链条。正向推导从假设走到检验它的实验；反向回看从结果走回能解释它们的 gap 和 contribution，并据此确定论文的叙事。两者都是正常的科研做法。

**谁改变什么。** 研究者改变微观叙事，出于新想法或对结果的回应，而且自己知道在改。只有研究者能动宏观框架或收窄 claim。agent 提议，不做决定。

## 编码 agent 做科研时会出什么问题

编码 agent 主要是在产品工程上训练出来的，它的习惯在科研里以无声的方式失效：结果看起来正常却是错的，或者是对的却无关紧要。问题出现在每一层。

**工程。**
- 把失败伪装成看似合理的数据：缺失值被默认值替换，解析失败被空字符串替换，API 错误被静默重试。数字看起来正常，其实是错的。
- 工程瞄错了目标：追求最小的 diff 而不是最清楚的最终状态，为假想的需求做抽象，在不需要的地方做仪式性的单元测试、dry-run 和哈希校验，而在错误无声的接缝处（mask、对齐、指标、数据划分）检查太少。

**Claim。**
- claim 被悄悄弱化（"提升"变成"可能有帮助"），表现差的设置被丢掉，范围在事后从看起来好的子集里挑出来。
- 交付物里塞满保护作者的句子（"这并不意味着……"、"结果仅为初步"），而不是把范围写进 claim 本身。

**叙事。** 这是 agent 最容易丢掉的一层，因为单看任何一步都看不出来。
- **长程工作中的漂移。** agent 陷入局部最优（工程正确性、数据质量、统计显著性），这条工作线不再回应 gap。每一步都合理且被批准过，所以研究者也没有察觉。一种相关的形式：agent 写出一个自己的微观叙事，一条能通过局部检验、却无法把宏观框架关心的效应与其明显的替代解释拆分开的路线，工作在它之下继续推进，而研究者从未确认过它。
- **缺少由 agent 发起的回看。** 被直接问到时，agent 能准确地讲出叙事。没被问到时，它会用 claim 去解读每一个新结果，但不会问当前这条工作线是否还在服务于 gap。实际上，这一层面的每一次回看都是研究者发起的。
- **相反的错误。** 把 claim 规则只按正向理解的 agent，会把一次合法的反向回看、或研究者自己转向新的微观叙事，当成违规，打断合理的工作。
- **回归时的倒退。** 停顿之后，agent 的 catch-up 是一份做了什么的变更日志；入口文档（README、handoff、决策登记表里的 Story 行）记下的是当天的具体实现，占据了叙事的位置。上下文压缩最多保留 claim 那一句，会丢掉 gap。

**连续性。** 把工作迁到另一台机器，丢的是仓库和产物的状态；停顿后回来，丢的是研究者脑子里的叙事和细节。两者需要不同的处理。

## 本仓库如何解决这些问题

**常驻规则。** [AGENTS.md](./AGENTS.md) 包含每一层的规则：委派子 agent、实现、失败与回退、实验与 claim、科研叙事、交付物、测试、成本与 git。可以作为全局指令文件（Claude Code 用 `~/.claude/CLAUDE.md`，Codex 用 `~/.codex/AGENTS.md`），也可以作为项目的 `AGENTS.md`。它在每次会话中加载，所以其中的规则在上下文压缩后仍然存在。`research-dev-discipline` skill 是它更完整的解释。

**工程与 claim。** `research-dev-discipline` 给出规则背后的理由和边界情形：失败要大声报错，追求最清楚的最终状态，claim 的范围要明确，先记录失败再收窄，交付物从研究者的立场写。`diagnosing-bugs` 和 `correctness-tests` 处理无声的 bug 和真正重要的少数测试。`spec-review` 对照方法部分或实验计划检查 diff。`grilling` 对计划或叙事定位做压力测试。`git-guardrails-claude-code` 在不可撤销的 git 命令前加上确定性的批准步骤。

**叙事。** `research-narrative` 让叙事保持在场，而不靠定时提醒：
- 项目根目录下一份归研究者所有的 `NARRATIVE.md`，包含宏观框架、当前微观叙事（标明是研究者确认的还是 agent 草稿）、以及此前的微观叙事和终结每一条的结果。它指向实验记录而不是复制它们；项目规则文件引用它，而不是重述叙事。
- **正向动作。** 任一方提出新路线时，agent 起草它的微观叙事，并在设计实验之前回答一个问题：这条路线即使在原理上，能否把宏观框架关心的效应与其明显的替代解释拆分开？
- **反向动作。** 当某个结果改变了证据所支持的 gap 或 contribution 时，agent 提出重新定位后的 gap 和 contribution，所有结果都保持在视野内，并指出能确认它的正向检验。由研究者决定。
- **每个决策点一行。** 每当 agent 请研究者做决定，它都写明这个决定服务于当前微观叙事的哪一部分。写不出来，就是回看：它在 gap 层面说明情况，让研究者来选。这利用的是本来就存在的时刻，只有在联系缺失时才打断，而联系缺失正是漂移的样子。
- 漂移以宏观框架和已确认的微观叙事为基准来衡量，而不是以固定计划为基准，所以研究者的转变和反向回看不会被误判。
- 术语表给出每个术语与研究者所用中文术语的对应，让两种语言指向同一套概念。

`narrative-hook-claude-code` 安装一个 Claude Code 钩子，每次压缩之后从 `NARRATIVE.md` 重新注入宏观框架和当前微观叙事，不论摘要保留了什么。

**连续性。** `catch-up` 处理同一台机器上停顿后的回归：只读，自上而下重讲叙事，然后讲这段时间发生了什么、每件事服务于叙事的哪一部分，再讲状态和待决定的事，并等研究者确认叙事。`handoff` 与 `pickup` 通过 git remote 在机器或会话之间迁移工程状态；handoff 会记下这次工作服务于当前微观叙事的哪一部分。

## Skills

**用户调用**的 skill 只在你输入时运行（例如 `/spec-review`）。**模型调用**的 skill 在任务合适时也可以由 agent 自行加载。

### 通用

适用于任何项目的科研与工程 skill。

**模型调用**

- **[research-dev-discipline](./skills/research-dev-discipline/SKILL.md)**：[AGENTS.md](./AGENTS.md) 中科研规则的完整解释，附每条规则背后的理由、示例与边界情形。在头脑风暴、你设定的科学或实验检查点、交付实验产物、以及解读失败或意外结果时加载。
- **[research-narrative](./skills/research-narrative/SKILL.md)**：让漏斗式叙事在长程科研工作中保持在场：一份归用户所有的 `NARRATIVE.md`，包含宏观框架、当前微观叙事和此前的微观叙事；提出路线时做正向检查，结果改变叙事时做反向回看，每个决策点用一行写明服务于叙事的哪一部分，回归与进度汇报先讲叙事。附中英术语表。
- **[catch-up](./skills/catch-up/SKILL.md)**：同一台机器上停顿之后，把你带回项目：从 `NARRATIVE.md` 自上而下讲叙事，然后是你离开期间发生了什么、当前状态和待决定的事。只读；等你确认叙事或选定下一步再继续。换机器请用 `pickup`。
- **[diagnosing-bugs](./skills/diagnosing-bugs/SKILL.md)**：科研代码中困难、无声 bug 的诊断循环：先建立一个能让这个 bug 变红的快速信号，再最小化、提出假设、加观测、带回归测试修复，并指出哪些结果需要重跑。
- **[correctness-tests](./skills/correctness-tests/SKILL.md)**：科研代码真正需要的少数测试，放在无声错误会改变结果的接缝处（指标、变换、数据划分、预处理、损失），每个都对照独立的参考实现检查。
- **[grilling](./skills/grilling/SKILL.md)**：对计划、实验设计、论文叙事定位、提案或 rebuttal 做毫不留情的追问，每轮问题都附推荐答案。事实是 agent 的事，决定是你的事。厘清含糊的术语，对照代码核实你的说法，并确保评测方案被覆盖。

**用户调用**

- **[git-guardrails-claude-code](./skills/git-guardrails-claude-code/SKILL.md)**：每台机器安装一次，一个 Claude Code 钩子：任何不可撤销的 git 命令（clean、hard reset、丢弃未提交的改动、删除 stash、强制推送）执行前都要你批准。
- **[narrative-hook-claude-code](./skills/narrative-hook-claude-code/SKILL.md)**：安装一个 Claude Code 钩子，每次上下文压缩之后把 `NARRATIVE.md` 中的宏观框架和当前微观叙事重新注入上下文。
- **[spec-review](./skills/spec-review/SKILL.md)**：检查某个固定点以来的 diff 是否符合论文方法部分、实验计划或 issue 的描述：数据划分、预处理、模型与训练设置、指标计算。
- **[handoff](./skills/handoff/SKILL.md)**：把工作和一份 handoff 文档（状态快照、决策、未决问题、下一步、需手动复制的产物）提交并推送到 git remote，供任何机器上的任何工具或模型接手。没有 git 或 remote 时取消。
- **[pickup](./skills/pickup/SKILL.md)**：从 handoff 恢复工作：在仓库内从 git remote 取回 handoff；在仓库外则根据复制来的 handoff 文件恢复它指定的仓库（遇到冲突文件会询问你）。然后核对快照和本机上 git 之外的产物，报告不一致，等你确认后继续。它迁移的是工程状态；长时间停顿之后，接着运行 `catch-up`。
- **[to-questionnaire](./skills/to-questionnaire/SKILL.md)**：把一个你无法独自做出的决定，变成一份问卷，交给唯一能回答的人（比如临床合作者），用对方的语言来写。

### 领域

面向某一研究方向的 skill，每个都在 `references/` 下附有知识库。

**模型调用**

- **[opd-research-coding](./skills/opd-research-coding/SKILL.md)**：on-policy distillation（OPD、OPSD、OPD+RLVR）的科研编码：训练前诊断、损失与估计器设计、必须记录的日志、症状到原因到修复的对照表、以及实验设计中的对照，背后是一个 2026 年 OPD 论文的知识库。

## 约定

- Skill 用英文写，不使用 em-dash。
- README 有英文（`README.md`）和简体中文（`README.zh-CN.md`）两份，顶部互相链接。两份要一起改。
- 各工具中的调用方式一致。用户调用的 skill 在 `SKILL.md` 中设置 `disable-model-invocation: true`（Claude Code），并在 `agents/openai.yaml` 中设置 `policy.allow_implicit_invocation: false`（Codex）；模型调用的 skill 两者都不设。两处要一起改。

## 许可证

MIT；见 [LICENSE](./LICENSE)。改编自 mattpocock/skills 并保留 Matt Pocock 版权的有：`diagnosing-bugs`、`correctness-tests`（源自 `tdd`）、`grilling`、`git-guardrails-claude-code`、`spec-review`（源自 `code-review`）、`handoff`、`to-questionnaire`。本仓库原创的有：`research-dev-discipline`、`research-narrative`、`catch-up`、`narrative-hook-claude-code`、`pickup`、`opd-research-coding` 和 `AGENTS.md`。
