# Relay：一句话启动科研协作

> 这是 **公共 Skill / 插件规范库**，不是科研数据仓库。统一入口：[README](../README.md)；示例：[Issue #17](https://github.com/yunmuxize/github-research-relay/issues/17) → [PR #18](https://github.com/yunmuxize/github-research-relay/pull/18)。

## 1. 两个 Skill

| 角色 | Skill 名称 | 负责 |
|---|---|---|
| ChatGPT | `research-relay-controller` | 讨论后的规划、选择项目仓库、创建任务 Issue、独立验收 PR、返工 |
| OpenCode / Codex | `research-relay-worker` | 从 Issue 执行任务，原子认领、独立分支、真实测试、PR 交付 |

ChatGPT 插件、GitHub 源文件、各服务器全局 Skill 是**三份独立安装**。更新 GitHub 不等于插件或服务器自动更新。优先以 `main` 上已验收的版本为来源；记录 Git SHA/本地文件哈希，升级前备份。ChatGPT 应用里的私有插件需要单独发布。

## 2. 首次进入新对话——一句话给 ChatGPT

> 请使用 **Research Relay Controller**，查看 `yunmuxize/github-research-relay` 的最新已验收工作流与本项目背景。我们先讨论 Idea；讨论结束后由你规划最小可验收任务、发布到正确的**项目仓库**，并给我发给 OpenCode 的一句话指令。

ChatGPT 应先尝试加载/使用已安装的 `research-relay-controller`，检查 GitHub 连接器和项目仓库。没有安装时明确说明，仍可依据 GitHub 文档及获授权的 GitHub 工具继续工作；**不能声称仅凭一句话自动安装插件**。

## 3. 讨论结束——一句话给 ChatGPT

> **把刚才确定的下一步写到 Relay，并给我发给 OpenCode 的一句话指令。**

Controller 应执行：
1. 判断是**已有项目**还是**全新项目**；已有项目持续使用同一私有仓库，**不同任务用不同 Issue**。不要把科研数据发布到这个公共框架仓库。
2. 核对已讨论目标、已有 Issue/PR、基线 Commit SHA、限制、实验/验收设计；信息不足时如实标注或提出必要问题。
3. 有目标仓库且有授权写权限时，实际发布具备清晰 Scope/Non-goals、Evidence、验收条件和报告渠道的 `relay:ready` Issue，并初始化 `relay:attempt attempt=1`；**核实操作成功**。
4. 输出 **OpenCode 可直接复制的一句话指令**，优先包含 **完整 Issue URL**，避免多项目环境中误选队列。
5. 没有私有项目仓库时，不要把任务错误地写到框架库；先生成下面的项目初始化指令给 OpenCode 执行，然后回到 ChatGPT 创建首个 Issue。

**推荐 OpenCode 指令（已有 Issue）：**

> 请显式加载 `research-relay-worker`，执行 `https://github.com/OWNER/PRIVATE-REPO/issues/N`；按任务契约和对应版本的 Skill 完成任务、真实测试并提交 PR，等待 Controller 验收。不要使用本地 TASK inbox，不要合并。

## 4. 没有项目仓库时——一次性 Bootstrap

由 ChatGPT 确认项目名称、目标、预计仓库名及**创建私有仓库的用户授权**。ChatGPT 连接器若没有创建 GitHub 仓库的能力，不得声称已建成；将 [PROJECT_BOOTSTRAP.md](../templates/PROJECT_BOOTSTRAP.md) 的精简指令交给具备 `gh repo create` 权限的 OpenCode，在服务器上完成：

- 查重、检查秘密信息、以 `--private` 建立项目仓库（仅在用户明确授权后）
- 创建最少的 README / AGENTS / 研究约束与 .gitignore；不得上传尚未授权的原有材料
- 验证 gh 授权、仓库可读写、Relay Worker Skill 与版本；记录仓库 URL 和初始 SHA
- 初始化完成后**停止，不自行发明科研任务**；用户把仓库 URL 交回 ChatGPT，Controller 发布首轮 Issue

**不建议所有服务器共用一个隐式 `RESEARCH_RELAY_REPO`。** 多项目时，ChatGPT 输出的完整 Issue URL 是最安全、最少配置的路由方式。

## 5. 验收和返工

用户回 ChatGPT 说：**“验收一下结果。”** Controller 从**本项目**的 `relay:review` 队列与已关联 PR 自动检索；若多项任务不明确，先确定目标。独立核验 Diff、Commit、测试、数据、问题与证据，不照抄 Worker 自评。

- `ACCEPT`：PR 评论记录事实和局限；Issue → `relay:done`；**不自动合并或关闭**。
- `REWORK`：原 PR 留用；PR 评论写可操作修复，创建新 attempt marker；Issue → `relay:ready`。下一轮仍执行**同一 Issue/PR**。
- `INSUFFICIENT EVIDENCE`：明确缺哪条证据，视情况标记 ready/blocked，不杜撰测试。

## 6. 维护与归档

- 公共框架库只保存 Skill、插件源、模板、安装指南和**匿名通用演示**。
- 演示历史：[#1/#2](https://github.com/yunmuxize/github-research-relay/issues/1)、[#3/#6](https://github.com/yunmuxize/github-research-relay/issues/3)、[#17/#18](https://github.com/yunmuxize/github-research-relay/issues/17)；这些是历史证据，**不要清理成无法审计的状态**。
- 研发项目每个独立仓库，优先 private；不公开未发表论文、原始数据、真实服务器信息或凭证。
- 要更新 Skill 时说：**“请检查 Relay 的 GitHub、ChatGPT Controller 插件和 OpenCode Worker 安装版本，列差异并在我同意后同步。”**
- 不承诺 webhook 自动唤醒 ChatGPT、不擅自合并、不自动执行破坏性操作；在安装了其他调度器的机器上**显式指定 Skill**，避免裸 `接一轮新任务` 路由冲突。
