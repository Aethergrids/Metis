---
name: run-long-job
description: >-
  启动并管理预计运行超过五分钟的本地命令，避免让语言模型进入轮询循环。适用于训练、
  backfill、migration、materialization、benchmark、大型 build、批量下载，或用户要求
  持续观察、反复检查、留到夜间运行的作业；也适用于前台命令在一次健康检查后仍未结束的
  情况。不用于普通交互命令或有界 Agent 推理。
---

# 运行长任务

将计算生命周期与 Agent 生命周期分离，并留下紧凑、持久的证据，供后续 turn 或新 task
一次性检查。

## 硬性规则

- 不要在模型 turn 之间交替执行 `sleep`、tail log、PID 检查、资源检查或 wait tool。
- 一个 task 最多进行一次启动健康检查和一次 terminal-state 检查。跨 resume 连续两次
  状态不变后停止，并留下 handoff。
- 不让 sub-agent 存活只为监控进程。
- 不通过 Agent 管理的 shell tool 调用本 skill 的 `wait` 命令；它只供外部非 LLM
  watcher 使用。
- “持续工作直到完成”授权将计算 detach，不授权轮询。

## 启动

相对于本 `SKILL.md` 解析 `scripts/long_job.py`，然后运行：

```bash
<skill-root>/scripts/long_job.py start \
  --name <short-name> \
  --cwd "$PWD" \
  -- <executable> <arg> ...
```

直接传入 argv vector。pipeline 或 redirection 必须显式使用 shell，例如
`-- sh -lc '<pipeline>'`。不要把 credential 放入命令行参数，因为 launcher 会把命令
和参数写入 `status.json`；使用继承的环境变量或项目 secret 机制。被启动的命令必须保持
前台运行并拥有其子进程，不要追加 `&`，也不要调用自 daemonize 模式。

launcher 会执行有界的非 LLM 健康检查，并返回一行紧凑 JSON，包含 run directory、state、
PID、log path、status path 和 terminal-sentinel path。它会记录 working directory、
command、parameter、Git SHA、tracked dirty state、timestamp 和 process identifier。
默认状态写入操作系统临时目录；需要指定持久位置时设置 `METIS_RUNS_DIR` 或传入 `--root`。

将返回结果视为启动健康检查。若状态为 `running`，停止使用工具并结束 turn，同时报告
run directory 和后续 resume 命令：

```bash
<skill-root>/scripts/long_job.py status <run-directory>
```

只有启动结果仍为 `starting` 时才立即调用一次 `status`，随后结束 turn。启动阶段失败时，
最多读取一次日志末尾 40 行。

## 里程碑

子进程会获得 `METIS_RUN_DIR`、`METIS_MILESTONE_PATH` 和 `METIS_LONG_JOB_CLI`。
协作式作业可发布一条简短里程碑：

```bash
"$METIS_LONG_JOB_CLI" milestone "$METIS_RUN_DIR" "epoch 4/20"
```

`status` 只返回最新里程碑。不要通过 tail 全量日志推断进度。

## Resume 与收尾

完成后优先使用新的、小 context 收尾 task。resume 时只运行一次 `status`：

- `running`：报告紧凑状态并停止；除非用户明确要求有界 follow-up，不安排下一次检查。
- `succeeded`：验证用户要求的 artifact，然后继续收尾。
- `failed` 或 `lost`：最多检查末尾 40 行日志，诊断一次，然后进行有界修复，或询问失败
  所需要的决策。

非 LLM shell watcher 可以使用以下命令；它在 terminal state 前不输出，结束时只返回一行
紧凑 JSON：

```bash
<skill-root>/scripts/long_job.py wait <run-directory>
```

不要在 Agent loop 中调用它。手动 resume 是成本最低的唤醒方式。用户明确要求 scheduled
follow-up 时，使用 30–60 分钟 cadence、硬性检查次数上限和持久停止条件；scheduled
检查仍消耗模型 turn，本身不是 completion event。
