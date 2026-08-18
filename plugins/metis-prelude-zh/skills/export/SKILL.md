---
name: export
description: >-
  将当前 .metis/context 工作区导出为使用 UUIDv7 标识的、可移植且兼容 Claude
  memory 的目录。适用于另一台 host 或 session orchestrator 需要从文件系统状态继续
  工作的场景。不创建 Agent 或转交任务，不同步 S3，也不把导出历史作为活动状态维护。
---

# 导出 Context Ledger

从当前 ledger 创建一个时间点文件系统 package。export 是复制操作，不是原子
`handoff`：它不创建 task、fork、session、sub-agent 或原生 handoff artifact。

若来源是未经整理的长 session，并且目标是将每个持久事实写成独立 Claude memory 文件，
使用 `$metis-prelude-zh:export-memory-context`。本 skill 只快照已经整理好的六文件
ledger，不再执行一轮 memory 提取。

## 准备来源

从 Git 根目录或当前目录定位 `.metis/context/`，其中必须包含：

- `MEMORY.md`
- `goal.md`
- `todo.md`
- `delegation-queue.md`
- `information-index.md`
- `learnings.md`

若上次更新后实质上下文发生变化，先按 `$metis-prelude-zh:update` 的规则整理。导出前
检查六个文件是否矛盾、next action 过期、相对链接损坏或包含 secret。白名单之外的文件
和原始 transcript 不得进入导出。

## 运行内置 exporter

相对于本 `SKILL.md` 解析 `../../scripts/export_context.py`，然后从工作区根目录运行。
默认读取 `.metis/context` 并写入 `.metis/exports`：

```bash
python3 /absolute/path/to/export_context.py
```

工作区是 Git checkout 时，传入当前 commit；不要求 working tree 干净：

```bash
python3 /absolute/path/to/export_context.py --git-commit <commit>
```

Python 3.14 及以上使用标准库 UUIDv7；较早版本使用 DuckDB。若 DuckDB 不可用且用户已经
授权安装 dependency，可安装插件声明的最低 fallback：

```bash
python3 -m pip install "duckdb>=1.5.5"
```

不要静默安装系统 package。未获得安装授权时，报告缺失 dependency 并停止，不留下部分
导出。

## 输出契约

脚本打印最终目录路径，结构如下：

```text
.metis/exports/exp_<uuidv7>/
├── MEMORY.md
├── goal.md
├── todo.md
├── delegation-queue.md
├── information-index.md
├── learnings.md
└── export.json
```

`export.json` 包含 `format_version`、`export_id`、`created_at`、`entrypoint`，以及
传入时的 `git_commit`。UUIDv7 只保证导出目录唯一且按时间可排序，不引入 project、
session、node、lineage 或 checkpoint 版本管理。

报告导出目录和 `MEMORY.md` 入口。用户可以自行运行 `aws s3 sync`；只有在其明确要求时
才执行网络同步。
