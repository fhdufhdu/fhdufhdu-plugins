---
name: english-reading-study
description: Run interactive English reading practice from a user-provided document URL, sentence by sentence, with concise translation feedback, vocabulary/grammar/weak-point capture, spaced review for 1/4/7/30-day due items, and persistent study records committed to the GitHub repository fhdufhdu/eng-reading-study.git. Use when the user asks to study English from an article, URL, document, reading passage, translation practice, daily English study, or review prior English study records.
---

# English Reading Study

## Purpose

Guide a daily English reading session. The user provides a document URL, translates one sentence at a time, receives brief correction-focused feedback, and gets durable records saved to the study repository.

Use the repository as the source of truth:

`https://github.com/fhdufhdu/eng-reading-study.git`

Before every session, make sure the repo is available locally and up to date. After every completed learning or review segment, update records, commit the changes, and push when credentials allow.

## Repository Setup

Use a stable local checkout:

`${CODEX_HOME:-$HOME/.codex}/data/eng-reading-study`

If it does not exist, clone it from GitHub. If it exists, pull with `--ff-only` before reading or writing records. If push fails because authentication is unavailable, keep the local commit and clearly tell the user.

If GitHub returns `Repository not found`, treat the repository as private or not yet created. Ask the user to confirm repository access, authenticate Git, or create the repository before relying on persistent storage.

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
7. Give concise feedback:
   - accuracy: correct / partial / incorrect
   - better translation when useful
   - one or two key reasons
   - vocabulary, idiom, grammar, usage, or structure worth remembering
8. Record weak points as they happen. Prefer specific labels: vocabulary, idiom, phrasal verb, preposition, tense/aspect, clause structure, modifier attachment, reference/pronoun, nuance, context inference, natural Korean rendering.
9. Continue sentence by sentence until the selected document portion is complete or the user stops.
10. Save the daily record and review cards.
11. Run due reviews for records from 1, 4, 7, and 30 days before today's date.
12. Update the old records with today's review result and any newly observed weak points.
13. Commit and push repository changes.

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
git pull --ff-only
```

After writing:

```bash
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
