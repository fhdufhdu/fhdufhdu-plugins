# English Reading Study Record Schema

Use these formats for durable study records. Keep records concise and easy to parse.

## Internal Configuration

Path:

`~/.english-reading-study/info.json`

The skill must create this file after receiving the user's study repository URL and cloning it into `~/.english-reading-study/repo`.

Schema:

```json
{
  "repo_url": "https://github.com/user/english-study-data.git",
  "repo_path": "/Users/name/.english-reading-study/repo",
  "default_branch": "main",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

Update `updated_at` when the repository configuration changes. Do not store document URLs, article content, or study history in `info.json`; those belong inside the cloned repository.

## Daily Record

Path:

`daily/YYYY/YYYY-MM-DD-slug.md`

Template:

```markdown
---
type: daily-study
date: YYYY-MM-DD
title: "Article title"
url: "https://example.com/article"
source: "Publication or site"
status: completed
difficulty: intermediate
review_offsets: [1, 4, 7, 30]
---

# YYYY-MM-DD - Article title

## Metadata

- URL:
- Source:
- Retrieved:
- Scope:
- Status:

## Sentence Log

### S001

Original excerpt:
> Short sentence or necessary excerpt only.

User translation:

Suggested translation:

Feedback:
- Accuracy:
- Key point:
- Weak point:
- Review priority:

Memory items:
- vocabulary:
- idiom:
- grammar/usage:

Review log:
- YYYY-MM-DD: initial study
```

## Review Summary

Path:

`reviews/YYYY/YYYY-MM-DD.md`

Template:

```markdown
---
type: review-summary
date: YYYY-MM-DD
offsets: [1, 4, 7, 30]
---

# Review Summary - YYYY-MM-DD

## Due Sources

- daily/YYYY/YYYY-MM-DD-slug.md: offset 1

## Results

### daily/YYYY/YYYY-MM-DD-slug.md / S001

Prompt:

User answer:

Feedback:
- Accuracy:
- Still weak:
- Improved:
- Next review priority:
```

## Review Cards

Path:

`cards/YYYY/YYYY-MM-DD-slug.jsonl`

Write one JSON object per line:

```json
{"id":"C001","date":"YYYY-MM-DD","source_record":"daily/YYYY/YYYY-MM-DD-slug.md","sentence_id":"S001","kind":"sentence","front":"Short original excerpt","back":"Suggested Korean translation and key point","weak_points":["clause structure"],"priority":"high","review_dates":["YYYY-MM-DD","YYYY-MM-DD","YYYY-MM-DD","YYYY-MM-DD"],"history":[{"date":"YYYY-MM-DD","result":"initial"}]}
```

Card kinds:

- sentence
- vocabulary
- idiom
- grammar
- usage
- weak-point

Priority values:

- high: missed or structurally important
- medium: partially correct or useful expression
- low: correct but worth retaining

## Source Metadata

Path:

`sources/YYYY/YYYY-MM-DD-slug.md`

Template:

```markdown
---
type: source
date: YYYY-MM-DD
title: "Article title"
url: "https://example.com/article"
source: "Publication or site"
copyright_note: "Full source text is not stored; only short excerpts necessary for study are retained."
---

# Source - Article title

## Notes

- Retrieval notes:
- Selected scope:
- Excluded material:
```

## Due Review Discovery

For a session on `TODAY`, inspect records whose dates are:

- TODAY - 1 day
- TODAY - 4 days
- TODAY - 7 days
- TODAY - 30 days

Prefer card files first because they are compact. If card files are missing, fall back to the matching daily records.

When a review is completed, update:

1. The relevant daily record's `Review log`.
2. The corresponding card line's `history`.
3. The day's review summary file.

Never store a full article body. Store short excerpts only where necessary for sentence-level feedback.
