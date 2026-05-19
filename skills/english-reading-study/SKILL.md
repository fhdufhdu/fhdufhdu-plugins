---
name: english-reading-study
description: 사용자 제공 문서 URL로 영어 리딩을 한 문장씩 학습하고, 간단한 번역 피드백, 단어/문법/약점 기록, 1/4/7/30일 간격 복습, ~/.english-reading-study 아래에 클론된 사용자 설정 Git 저장소 커밋을 수행합니다. 영어 기사, URL, 문서, 리딩 지문, 번역 연습, 매일 영어공부, 학습 저장소 설정, 이전 영어 학습 복습 요청에 사용합니다.
---

# English Reading Study

## Purpose

Guide a daily English reading session. The user provides a document URL, translates one sentence at a time, receives brief correction-focused feedback, and gets durable records saved to the study repository.

Use the user-configured study repository as the source of truth for learning data. This repository only distributes the skill; it is not the default data store.

Before every session, make sure the user's study repo is configured, available locally, and up to date. After every completed learning or review segment, update records, commit the changes, and push when credentials allow.

## Repository Setup

Use this internal storage root:

`~/.english-reading-study`

Use this local checkout for the user's study data:

`~/.english-reading-study/repo`

Use this configuration file:

`~/.english-reading-study/info.json`

If `info.json` is missing or invalid, ask the user for the Git repository URL to use for study records. Then create the internal storage root, clone the repository into `repo`, and write `info.json`.

`info.json` must include:

```json
{
  "repo_url": "https://github.com/user/english-study-data.git",
  "repo_path": "/Users/name/.english-reading-study/repo",
  "default_branch": "main",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

If `repo` already exists, verify it is a Git repository and that `git remote get-url origin` matches `info.json.repo_url`. If it does not match, stop and ask the user whether to switch repositories.

If the repository URL cannot be cloned, tell the user the exact failure and ask them to confirm the URL, create the repository, or authenticate Git.

If the repo exists and matches, pull with `--ff-only` before reading or writing records. If push fails because authentication is unavailable, keep the local commit and clearly tell the user.

Create these directories when missing:

```text
daily/
reviews/
cards/
sources/
```

Read `references/record-schema.md` before creating or modifying study files.

## Session Workflow

1. Accept a document URL from the user.
2. Fetch the page or document and identify title, source, date, and difficulty.
3. Do not reproduce the full copyrighted document in chat or records. Work with one sentence at a time and store only necessary excerpts for study.
4. Split the document into study sentences. Skip navigation, ads, captions, boilerplate, and duplicated text.
5. Present exactly one sentence and ask the user to translate it into Korean.
6. Wait for the user's answer.
7. If the user asks a question instead of translating, answer the question briefly, do not mark the sentence as attempted, then present the same sentence again and ask the user to translate it into Korean.
8. Give concise feedback only after the user provides a translation:
   - accuracy: correct / partial / incorrect
   - better translation when useful
   - one or two key reasons
   - vocabulary, idiom, grammar, usage, or structure worth remembering
9. Record weak points as they happen. Prefer specific labels: vocabulary, idiom, phrasal verb, preposition, tense/aspect, clause structure, modifier attachment, reference/pronoun, nuance, context inference, natural Korean rendering.
10. Continue sentence by sentence until the selected document portion is complete or the user stops.
11. Save the daily record and review cards.
12. Run due reviews for records from 1, 4, 7, and 30 days before today's date.
13. Update the old records with today's review result and any newly observed weak points.
14. Commit and push repository changes.

## Question Handling During Translation

When waiting for a translation, distinguish a translation attempt from a question. If the user asks about vocabulary, grammar, sentence structure, background context, study flow, or asks for a hint, answer that question first.

After answering, re-show the same original sentence and ask for the Korean translation again. Do not advance to the next sentence and do not record accuracy until the user actually attempts a translation.

Use this shape:

```text
질문 답변: ...

다시 이 문장을 해석해 주세요.
Original sentence...
```

If the question reveals a likely weak point, remember it as a candidate weak point, but confirm it through the user's later translation before assigning review priority.

## Review Policy

Use the current date from the environment. The default review offsets are:

```text
1 day, 4 days, 7 days, 30 days
```

Do not review every old sentence by default. Select review items by priority:

- 1-day review: most high-priority missed sentences, key expressions, and core vocabulary
- 4-day review: missed sentences and expressions still likely to decay
- 7-day review: only difficult sentences and recurring weak points
- 30-day review: durable phrases, grammar patterns, and sentences previously marked high priority

If the user explicitly asks for full review, review the entire due record.

## Feedback Style

Keep feedback short and useful. Avoid long grammar lectures unless the user asks.

Use this shape:

```text
판정: partial
더 자연스러운 해석: ...
핵심: "as"가 이유가 아니라 동시 상황을 나타냅니다.
기억할 점: as + clause = ~하면서 / ~할 때 문맥 가능
복습 우선순위: high
```

When the user's translation is good, confirm briefly and still capture any phrase worth remembering.

## Record Keeping

Write repository-facing documents and study records in Korean. Keep machine-readable keys, directory names, file names, YAML frontmatter keys, and JSON keys in English for compatibility, but use Korean for Markdown headings, labels, feedback, explanations, review notes, and README-style documentation.

Use stable IDs so later reviews can reference the same item:

```text
S001, S002, ...
C001, C002, ...
```

Daily records go under:

`daily/YYYY/YYYY-MM-DD-slug.md`

Review summaries go under:

`reviews/YYYY/YYYY-MM-DD.md`

Reusable review cards go under:

`cards/YYYY/YYYY-MM-DD-slug.jsonl`

Source metadata goes under:

`sources/YYYY/YYYY-MM-DD-slug.md`

Always include:

- URL
- title
- source
- study date
- status
- sentence IDs
- user translation
- corrected or suggested translation
- concise feedback
- weak points
- review priority
- review log

## Git Discipline

Before writing:

```bash
cd ~/.english-reading-study/repo
git pull --ff-only
```

After writing:

```bash
cd ~/.english-reading-study/repo
git status --short
git add daily reviews cards sources
git commit -m "Add English study record for YYYY-MM-DD"
git push
```

If only review records changed, use:

```bash
git commit -m "Update English review records for YYYY-MM-DD"
```

Do not overwrite unrelated user changes in the repository. If there are unexpected local changes, inspect them and preserve them.

## Stop Conditions

If the document is too long, suggest a concrete stopping point such as 10-15 sentences or one section. If the page cannot be fetched, ask the user to paste the text or provide another URL. If the repository cannot be cloned or updated, continue the learning session in chat only after telling the user that persistence is blocked.
