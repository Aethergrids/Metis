# <导出名称>

本目录按 Claude memory tool 的形态组织，可以无需重构地合并进项目 memory 目录。

## 目录

```text
<export-name>/
├── MEMORY.md     可追加到项目 MEMORY.md 的索引行
├── memory/       每项事实一个文件，使用 memory-tool frontmatter
└── assets/       memory 引用的大型参考材料
```

## 集成

1. 将 `memory/*.md` 复制到项目 memory 目录
   （`~/.claude/projects/<project-slug>/memory/`）。
2. 将 `MEMORY.md` 中的行追加到该目录的 `MEMORY.md` 索引。
3. 将 `assets/` 复制到持久位置；若路径变化，更新 memory 文件内的 `assets/...` 引用。

`[[<existing-memory>]]` 已被引用但未包含，因为项目现有 memory 已覆盖 <内容>。不要重复。

## 阅读顺序

1. `assets/<narrative>.md` — 这项工作为何存在。
2. `assets/<constraints>.md` — 任何方案必须满足的约束。
3. `assets/<schema-or-state>` — 当前实际状态。
4. `assets/<handoff>.md` — 状态、下一步和 resume prompt。

## Assets

| 文件 | 内容 |
|---|---|
| | |

## 一句话摘要

<用两三句话说明当前情况，并包含关键数值>
