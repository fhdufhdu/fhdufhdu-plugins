# English Reading Study

Personal English reading practice plugin.

The plugin stores runtime configuration under:

```text
~/.english-reading-study/info.json
```

The user's learning data repository is cloned under:

```text
~/.english-reading-study/repo
```

On first use, the skill asks for the Git repository URL that should store study records, clones it, and saves the URL plus local clone path to `info.json`.

## Data Layout

- `~/.english-reading-study/repo/daily/`: daily sentence-by-sentence study records
- `~/.english-reading-study/repo/reviews/`: review session summaries
- `~/.english-reading-study/repo/cards/`: reusable review cards in JSONL
- `~/.english-reading-study/repo/sources/`: source metadata without full copyrighted article bodies
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
