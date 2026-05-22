---
name: capture
description: Humanities Wiki에 인문학 영상, 에세이 링크, 요약, 의미 깊었던 문구, 개인 성찰을 기록합니다. Karpathy의 LLM wiki 패턴처럼 raw source, wiki, schema, index.md, log.md를 유지하고 ~/.humanities-wiki/repo에 커밋합니다. 설정이 없으면 humanities-wiki:init 스킬을 먼저 사용합니다.
---

# Humanities Wiki Capture

## Purpose

Capture humanities videos, essays, talks, and meaningful passages into a durable personal wiki.

Follow Andrej Karpathy's LLM wiki pattern: the user curates sources and asks good questions; the LLM maintains the wiki as a persistent, compounding artifact. Do not merely save a link list. Each ingest should update the interlinked markdown wiki so later questions build on prior synthesis instead of rediscovering it from scratch.

Before every session, make sure the user's data repo is configured, available locally, and up to date. If it is not configured, use `humanities-wiki:init` first and do not continue the capture workflow until setup succeeds.

## Repository Setup Check

Use this internal storage root:

`~/.humanities-wiki`

Use this local checkout for the user's wiki data:

`~/.humanities-wiki/repo`

Use this configuration file:

`~/.humanities-wiki/info.json`

Before reading or writing records:

1. Verify `~/.humanities-wiki/info.json` exists and is valid JSON.
2. Verify `~/.humanities-wiki/repo` exists and is a Git repository.
3. Verify `git remote get-url origin` matches `info.json.repo_url`.
4. If any check fails, tell the user that setup is required and use `humanities-wiki:init`.
5. If the repo exists and matches, pull with `--ff-only`.

Create these paths when missing:

```text
raw/
raw/fulltext/
sources/
quotes/
reflections/
wiki/concepts/
wiki/people/
wiki/works/
wiki/themes/
wiki/questions/
index.md
log.md
AGENTS.md
```

Read `references/wiki-schema.md` before creating or modifying wiki files.

## Capture Workflow

1. Accept one or more user-provided URLs for humanities videos, essays, talks, interviews, poems, lectures, or related materials.
2. Ask the user for meaningful phrases or passages if they have not provided them yet. If the user already provided phrases, do not ask again.
3. Fetch the source when possible and identify title, creator, publication platform, date, language, medium, and URL.
4. Decide raw text storage policy before saving full source text, transcript, or subtitles:
   - Default: do not save full copyrighted material. Store summaries, metadata, user-provided phrases, and short necessary excerpts only.
   - If the user explicitly asks to store the full original text, transcript, or subtitles, warn them first: if the data repository is public or later shared, saving copyrighted full text may create copyright risk. Ask for confirmation before writing full text.
   - If confirmed, save full text under `raw/fulltext/YYYY/YYYY-MM-DD-slug.md` and mark the related source record with `fulltext_saved: true`, `fulltext_path`, and `copyright_risk_note`.
   - If the user declines or is unsure, keep `fulltext_saved: false` and store only summaries and short excerpts.
5. Write or update a source record under `sources/YYYY/YYYY-MM-DD-slug.md`.
6. Write quote records under `quotes/YYYY/YYYY-MM-DD-slug.md`, preserving the user's meaningful phrases and recording why they mattered.
7. Write a reflection entry under `reflections/YYYY/YYYY-MM-DD-slug.md` when the user expresses personal change, aspiration, discomfort, contradiction, or a new question.
8. Update the LLM-owned wiki:
   - create or revise pages in `wiki/concepts/`, `wiki/people/`, `wiki/works/`, `wiki/themes/`, and `wiki/questions/`
   - add cross-links using standard markdown wiki links or relative markdown links consistently with existing files
   - preserve tensions and contradictions instead of forcing a single clean thesis
   - note how the new source changes, deepens, or challenges prior pages
9. Update `index.md` with each touched page, a one-line Korean summary, and source count when useful.
10. Append an entry to `log.md` using this prefix:

```markdown
## [YYYY-MM-DD] ingest | Source Title
```

11. Commit and push repository changes.

## Query Workflow

When the user asks a question about their humanities wiki:

1. Read `index.md` first.
2. Search relevant wiki pages and source records.
3. Answer in Korean with links or path references to relevant local wiki files.
4. If the answer creates a durable synthesis, ask whether to file it back into `wiki/questions/` or another relevant page. If the user agrees, update the wiki, `index.md`, and `log.md`.

## Lint Workflow

When the user asks to check, clean up, or improve the wiki:

1. Read `index.md` and recent entries in `log.md`.
2. Look for orphan pages, stale claims, missing cross-references, repeated pages, unresolved contradictions, and important concepts without pages.
3. Propose concise fixes.
4. After approval, update the relevant pages, `index.md`, and `log.md`.

## Voice and Boundaries

Write in Korean with care and humility. The user is trying to become a better, deeper person; do not flatten that into productivity language. Keep records concrete: what source was encountered, what phrase mattered, what it revealed, what question remains, and how it connects to prior sources.

Do not overstate the user's transformation. Prefer grounded language such as "오늘 남은 질문", "흔들린 믿음", "다시 보고 싶은 문장", "내가 놓치고 있던 관점".

## Git Discipline

Before writing:

```bash
cd ~/.humanities-wiki/repo
git pull --ff-only
```

After writing:

```bash
cd ~/.humanities-wiki/repo
git status --short
git add raw sources quotes reflections wiki index.md log.md AGENTS.md
git commit -m "Add humanities wiki capture for YYYY-MM-DD"
git push
```

If only wiki maintenance changed, use:

```bash
git commit -m "Update humanities wiki maintenance for YYYY-MM-DD"
```

Do not overwrite unrelated user changes in the repository. If there are unexpected local changes, inspect them and preserve them.

## Stop Conditions

If a page cannot be fetched, ask the user to paste the text, transcript, or key parts they want to preserve. If the repository cannot be cloned or updated, use `humanities-wiki:init` if setup is missing; otherwise continue the discussion in chat only after telling the user that persistence is blocked.
