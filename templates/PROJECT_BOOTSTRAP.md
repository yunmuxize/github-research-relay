# Research Relay — 私有科研项目一次性初始化契约

此文档供 ChatGPT **生成给 OpenCode 的启动指令**，不是把研究材料写入公共框架库的许可。

## 用户必须先明确的最少信息

- GitHub 目标：`OWNER/PROJECT-REPO`
- 可见性：`private`（默认）
- 项目研究目标：一两句（不要虚构技术细节）
- 创建新 GitHub 仓库的明确授权

## 给 OpenCode 的可复用指令

> 请显式加载 `research-relay-worker`，参考 `https://github.com/yunmuxize/github-research-relay` 的 `docs/ONE_LINE_WORKFLOW.md` 和本文件。**我授权你创建 `OWNER/PROJECT-REPO` 的 GitHub 私有仓库**；如已存在则核验后复用。使用已有 `gh` 凭据，不记录、复制或上传 Token。检查当前本地文件、`.gitignore` 和权限后再运行 `gh repo create OWNER/PROJECT-REPO --private`（具体命令按本地项目状态调整）。最小化创建 `README.md`、`AGENTS.md`、`.gitignore` 和研究说明，记录源代码基线/实验环境中**可公开到此私有仓库的部分**。确认本机 `research-relay-worker` 版本与框架主分支已验收版一致；只初始化项目，不自动研究、不创建任务 PR、不合并。返回仓库 URL、初始 Commit SHA、Skill 路径/版本、权限结果及阻塞项。

## 初始化完成后

将仓库 URL 回复给 ChatGPT。Controller 根据本次研究讨论在**这个私有项目仓库**里创建首个 `relay:ready` Issue；OpenCode 下次只需要收到包含完整 Issue URL 的一句话。

## 原则

不同研究项目使用不同私有仓库；**同一项目每一轮研究任务都用同一个仓库的新 Issue**。不要误将具体科研仓库设置成公共 Relay 插件规范库。
