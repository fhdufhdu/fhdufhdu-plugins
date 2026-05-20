---
name: study
description: BookJakBookJak 영어 리딩 학습과 복습을 진행합니다. 사용자 제공 문서 URL을 문장 단위로 학습하고, 번역 피드백, 단어/문법/약점 기록, 1/4/7/30일 복습, ~/.bookjakbookjak/repo 커밋을 수행합니다. 설정이 없으면 bookjakbookjak:init 스킬을 먼저 사용합니다.
---

# BookJakBookJak Study

## Purpose

Guide a daily English reading session. The user provides a document URL, translates one sentence at a time, receives brief correction-focused feedback, and gets durable records saved to the configured study repository.

Use the user-configured study repository as the source of truth for learning data. This plugin only distributes skills; it is not the default data store.

Before every session, make sure the user's study repo is configured, available locally, and up to date. If it is not configured, use `bookjakbookjak:init` first and do not continue the study workflow until setup succeeds.

## Repository Setup Check

Use this internal storage root:

`~/.bookjakbookjak`

Use this local checkout for the user's study data:

`~/.bookjakbookjak/repo`

Use this configuration file:

`~/.bookjakbookjak/info.json`

Before reading or writing records:

1. Verify `~/.bookjakbookjak/info.json` exists and is valid JSON.
2. Verify `~/.bookjakbookjak/repo` exists and is a Git repository.
3. Verify `git remote get-url origin` matches `info.json.repo_url`.
4. If any check fails, tell the user that setup is required and use `bookjakbookjak:init`.
5. If the repo exists and matches, pull with `--ff-only`.

Create these directories when missing:

```text
daily/
reviews/
cards/
sources/
persistent/
```

Read `references/record-schema.md` before creating or modifying study files.

## Session Workflow

1. Accept a document URL from the user.
2. Fetch the page or document and identify title, source, date, and difficulty.
3. Do not reproduce the full copyrighted document in chat or records. Work with one sentence at a time and store only necessary excerpts for study.
4. Split the document into study sentences. Skip navigation, ads, captions, boilerplate, and duplicated text.
5. Before new reading, show a short warm-up from persistent weak items if any exist.
6. Present exactly one sentence and ask the user to translate it into Korean.
7. Wait for the user's answer.
8. If the user asks a question instead of translating, answer the question briefly, do not mark the sentence as attempted, then present the same sentence again and ask the user to translate it into Korean.
9. Give concise feedback only after the user provides a translation:
   - accuracy: correct / partial / incorrect
   - better translation when useful
   - one or two key reasons
   - vocabulary, idiom, grammar, usage, or structure worth remembering
10. Record weak points as they happen. Prefer specific labels: vocabulary, idiom, phrasal verb, preposition, tense/aspect, clause structure, modifier attachment, reference/pronoun, nuance, context inference, natural Korean rendering.
11. Promote repeatedly missed or repeatedly questioned items into persistent weak items.
12. Continue sentence by sentence until the selected document portion is complete or the user stops.
13. Save the daily record and review cards.
14. Run due reviews for records from 1, 4, 7, and 30 days before today's date.
15. Update the old records with today's review result and any newly observed weak points.
16. Update persistent weak items based on today's misses, improvements, and successful recalls.
17. Commit and push repository changes.

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

## Persistent Weak Items

Keep long-running weak items under:

`persistent/weak-items.jsonl`

Use this file for items the user repeatedly fails to recall, repeatedly mistranslates, or repeatedly asks about across sessions. These are separate from ordinary 1/4/7/30-day review cards because they should keep appearing until the user demonstrates stable recall.

Promote an item into persistent weak items when any of these are true:

- the same vocabulary, idiom, grammar pattern, or sentence structure is missed at least twice
- the user asks about the same point in multiple sessions
- a high-priority review item remains weak after review
- the item is foundational and blocks understanding of many sentences

At the start of each study session, show 3-7 active persistent weak items before the new document. Keep this warm-up short: ask for recall, a quick translation, or a usage explanation, then give concise feedback.

During the session, also reuse persistent weak items when they naturally connect to the current sentence. Do not overload the user; prefer a few high-value exposures over a long drill.

Update each persistent item after exposure:

- increase `miss_count` when the user cannot recall it
- increase `success_count` when the user recalls it correctly
- update `last_seen` on every exposure
- set `status` to `active`, `watch`, or `retired`

Move an item from `active` to `watch` after at least 3 successful recalls across different days. Move it to `retired` only after it remains correct after a later review. Retired items do not need daily exposure, but may be sampled occasionally.

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

Persistent weak items go under:

`persistent/weak-items.jsonl`

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
cd ~/.bookjakbookjak/repo
git pull --ff-only
```

After writing:

```bash
cd ~/.bookjakbookjak/repo
git status --short
git add daily reviews cards sources persistent
git commit -m "Add English study record for YYYY-MM-DD"
git push
```

If only review records changed, use:

```bash
git commit -m "Update English review records for YYYY-MM-DD"
```

Do not overwrite unrelated user changes in the repository. If there are unexpected local changes, inspect them and preserve them.

## Stop Conditions

If the document is too long, suggest a concrete stopping point such as 10-15 sentences or one section. If the page cannot be fetched, ask the user to paste the text or provide another URL. If the repository cannot be cloned or updated, use `bookjakbookjak:init` if setup is missing; otherwise continue the learning session in chat only after telling the user that persistence is blocked.
