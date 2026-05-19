# English Reading Study

Personal English reading practice repository and plugin.

## Data Layout

- `daily/`: daily sentence-by-sentence study records
- `reviews/`: review session summaries
- `cards/`: reusable review cards in JSONL
- `sources/`: source metadata without full copyrighted article bodies
- `plugins/english-reading-study/`: Codex and Claude plugin package

## Codex Plugin

The plugin lives at:

```text
plugins/english-reading-study
```

It includes:

- `.codex-plugin/plugin.json`
- `skills/english-reading-study/SKILL.md`
- `skills/english-reading-study/references/record-schema.md`

The repo also includes a Codex marketplace file:

```text
.agents/plugins/marketplace.json
```

## Claude Plugin

The same plugin folder includes:

```text
plugins/english-reading-study/.claude-plugin/plugin.json
```

For local testing after cloning this repository:

```bash
claude --plugin-dir ./plugins/english-reading-study
```

Then use the namespaced skill:

```text
/english-reading-study:english-reading-study
```

## Study Prompt

Use a prompt like:

```text
이 URL로 영어공부 시작해줘: https://example.com/article
```
