---
name: think
description: Humanities Wiki에서 사용자가 자유롭게 적은 생각을 정리하고, 이전 reflections/wiki/quotes/sources를 바탕으로 질문에 답합니다. 생각 덤프, 일기, 자기 성찰, 관점 정리, 기록 기반 질의응답, ~/.humanities-wiki/repo 커밋이 필요할 때 사용합니다. 설정이 없으면 humanities-wiki:init 스킬을 먼저 사용합니다.
---

# Humanities Wiki Think

## Purpose

Help the user pour out messy thoughts, then turn them into durable reflections and wiki connections.

Use this skill when the user:

- writes a loose stream of thoughts and asks to organize it
- wants a journal-like reflection saved into Humanities Wiki
- asks questions based on their previous thoughts, quotes, sources, or wiki pages
- wants help naming what they are feeling, believing, avoiding, seeking, or becoming

This is not a productivity summary. Treat the user's rough thoughts as raw material for self-understanding.

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
reflections/
wiki/concepts/
wiki/themes/
wiki/questions/
index.md
log.md
AGENTS.md
```

When writing records, follow `../capture/references/wiki-schema.md` for wiki page, index, and log conventions.

## Thought Organizing Workflow

1. Accept the user's raw thoughts as-is. Do not correct tone, make it polished, or rush to advice.
2. If the user has not asked a direct question, organize the thought into these sections:
   - `흐름`: the user's thought in a clearer order
   - `핵심 감정`: emotions or tensions that appear
   - `반복되는 믿음`: assumptions, values, fears, or desires that recur
   - `남은 질문`: questions that are alive but unresolved
   - `연결되는 기록`: relevant existing sources, quotes, reflections, or wiki pages
   - `한 문장으로 남기기`: a concise sentence worth remembering
3. Ask whether to save the organized reflection unless the user already asked to save it.
4. If saving, write `reflections/YYYY/YYYY-MM-DD-slug.md`.
5. Update relevant `wiki/concepts/`, `wiki/themes/`, or `wiki/questions/` pages only when the thought creates a durable pattern, recurring theme, or important question.
6. Update `index.md` and append a `think` entry to `log.md`.
7. Commit and push repository changes.

## Question Answering Workflow

When the user asks a question based on their own records:

1. Read `index.md` first.
2. Search likely relevant files under `reflections/`, `quotes/`, `sources/`, and `wiki/`.
3. Answer in Korean using the user's record as the primary ground. If the records do not support a strong answer, say so.
4. Separate:
   - what the records show
   - what is an interpretation
   - what remains uncertain
5. End with one or two useful follow-up questions only when they genuinely deepen the user's inquiry.
6. If the answer is worth preserving, ask whether to save it under `wiki/questions/` or a relevant theme page. If the user agrees, update the wiki, `index.md`, and `log.md`.

## Reflection Record Shape

Use this shape for thought records:

```markdown
---
type: reflection
date: YYYY-MM-DD
mode: thought
status: captured
related:
  - "wiki/themes/example.md"
---

# 생각 정리 - YYYY-MM-DD

## 원문에 가까운 기록

사용자의 생각을 과하게 다듬지 않고 필요한 만큼 보존한다.

## 흐름

## 핵심 감정

## 반복되는 믿음

## 남은 질문

## 연결되는 기록

## 한 문장으로 남기기
```

## Voice

Write in Korean. Be direct, careful, and humane. Do not flatter the user or dramatize their growth. Prefer grounded phrasing:

- "이 생각에는 두 갈래가 있습니다."
- "여기서 반복되는 기준은 ..."
- "기록만 보면 아직 단정하기 어렵습니다."
- "이 질문은 `wiki/questions/`에 남길 만합니다."

Avoid turning every reflection into a lesson. Sometimes the right output is a clean structure and one honest question.

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
git add reflections wiki index.md log.md AGENTS.md
git commit -m "Add humanities thought record for YYYY-MM-DD"
git push
```

If only question/wiki maintenance changed, use:

```bash
git commit -m "Update humanities question notes for YYYY-MM-DD"
```

Do not overwrite unrelated user changes in the repository. If there are unexpected local changes, inspect them and preserve them.

## Stop Conditions

If the repo cannot be cloned or updated, use `humanities-wiki:init` if setup is missing. If persistence is blocked for another reason, continue organizing the thought in chat only after telling the user that saving is blocked.
