---
name: init
description: BookJakBookJak 영어 리딩 학습 데이터 저장소를 설정하거나 점검합니다. ~/.fhdufhdu/config/bookjakbookjak.json 생성, ~/.fhdufhdu/bookjakbookjak Git 저장소 클론, 원격 URL 검증, 기본 기록 디렉터리 생성이 필요할 때 사용합니다.
---

# BookJakBookJak Init

## Purpose

Configure the user's English reading study data repository for BookJakBookJak.

Use this skill when:

- `~/.fhdufhdu/config/bookjakbookjak.json` is missing or invalid
- `~/.fhdufhdu/bookjakbookjak` is missing
- the configured data repository remote does not match the local checkout
- the user asks to set up, reset, or check the study data repository

## Storage

Use this internal storage root:

`~/.fhdufhdu`

Use this configuration file:

`~/.fhdufhdu/config/bookjakbookjak.json`

Use this local checkout for study data:

`~/.fhdufhdu/bookjakbookjak`

`bookjakbookjak.json` must include:

```json
{
  "repo_url": "https://github.com/user/english-study-data.git",
  "repo_path": "/Users/name/.fhdufhdu/bookjakbookjak",
  "default_branch": "main",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

Do not store document URLs, article text, study records, or review history in `bookjakbookjak.json`.

## Setup Workflow

1. Check whether `~/.fhdufhdu/config/bookjakbookjak.json` exists and is valid JSON.
2. If it is missing or invalid, ask the user for the Git repository URL to use for study records.
3. Create `~/.fhdufhdu/config`.
4. Clone the repository into `~/.fhdufhdu/bookjakbookjak`.
5. Write `bookjakbookjak.json` with `repo_url`, `repo_path`, `default_branch`, `created_at`, and `updated_at`.
6. If `~/.fhdufhdu/bookjakbookjak` already exists, verify it is a Git repository.
7. Verify `git remote get-url origin` matches `bookjakbookjak.json.repo_url`.
8. If the remote does not match, stop and ask the user whether to switch repositories.
9. Pull with `--ff-only` when the repo exists and matches.
10. Create these directories when missing:

```text
daily/
reviews/
cards/
sources/
persistent/
```

11. Commit and push directory placeholder changes only if files were actually created.

If the repository URL cannot be cloned, tell the user the exact failure and ask them to confirm the URL, create the repository, or authenticate Git.

If push fails because authentication is unavailable, keep the local commit and clearly tell the user.

## Completion

After successful setup, tell the user:

```text
BookJakBookJak 데이터 저장소 설정이 완료되었습니다.
설정 파일: ~/.fhdufhdu/config/bookjakbookjak.json
데이터 저장소: ~/.fhdufhdu/bookjakbookjak
```
