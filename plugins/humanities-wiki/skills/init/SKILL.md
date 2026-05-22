---
name: init
description: Humanities Wiki 데이터 저장소를 설정하거나 점검합니다. ~/.humanities-wiki/info.json 생성, 데이터 Git 저장소 클론, 원격 URL 검증, LLM wiki 기본 디렉터리와 AGENTS.md 생성이 필요할 때 사용합니다.
---

# Humanities Wiki Init

## Purpose

Configure the user's personal humanities wiki data repository.

Use this skill when:

- `~/.humanities-wiki/info.json` is missing or invalid
- `~/.humanities-wiki/repo` is missing
- the configured data repository remote does not match the local checkout
- the user asks to set up, reset, or check the Humanities Wiki data repository

## Storage

Use this internal storage root:

`~/.humanities-wiki`

Use this configuration file:

`~/.humanities-wiki/info.json`

Use this local checkout for wiki data:

`~/.humanities-wiki/repo`

`info.json` must include:

```json
{
  "repo_url": "https://github.com/user/humanities-wiki-data.git",
  "repo_path": "/Users/name/.humanities-wiki/repo",
  "default_branch": "main",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

Do not store document URLs, source records, quotes, or reflections in `info.json`.

## Setup Workflow

1. Check whether `~/.humanities-wiki/info.json` exists and is valid JSON.
2. If it is missing or invalid, ask the user for the Git repository URL to use for Humanities Wiki records.
3. Create `~/.humanities-wiki`.
4. Clone the repository into `~/.humanities-wiki/repo`.
5. Write `info.json` with `repo_url`, `repo_path`, `default_branch`, `created_at`, and `updated_at`.
6. If `~/.humanities-wiki/repo` already exists, verify it is a Git repository.
7. Verify `git remote get-url origin` matches `info.json.repo_url`.
8. If the remote does not match, stop and ask the user whether to switch repositories.
9. Pull with `--ff-only` when the repo exists and matches.
10. Create these directories when missing:

```text
raw/
sources/
quotes/
reflections/
wiki/concepts/
wiki/people/
wiki/works/
wiki/themes/
wiki/questions/
```

11. Create `index.md`, `log.md`, and `AGENTS.md` when missing.
12. Commit and push setup changes only if files were actually created.

## Repository AGENTS.md

When creating `AGENTS.md` in the data repository, include these operating rules:

- Treat `raw/` and `sources/` as source-of-truth records. Do not rewrite original metadata except to correct factual errors.
- The LLM owns `wiki/`, `index.md`, and `log.md`; keep them current after every source ingest or substantial query.
- Update relevant concept, person, work, theme, and question pages whenever a new source changes the synthesis.
- Record contradictions, tensions, and changed interpretations instead of smoothing them away.
- Keep `index.md` content-oriented and `log.md` chronological.
- Write records in Korean while keeping path names and frontmatter keys in English.
- Do not save full copyrighted source text. Save links, metadata, summaries, short necessary excerpts, and user-provided meaningful phrases.

## Completion

After successful setup, tell the user:

```text
Humanities Wiki 데이터 저장소 설정이 완료되었습니다.
설정 파일: ~/.humanities-wiki/info.json
데이터 저장소: ~/.humanities-wiki/repo
```
