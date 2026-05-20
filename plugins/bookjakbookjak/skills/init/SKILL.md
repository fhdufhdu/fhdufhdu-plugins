---
name: init
description: BookJakBookJak 영어 리딩 학습 데이터 저장소를 설정하거나 점검합니다. ~/.bookjakbookjak/info.json 생성, 데이터 Git 저장소 클론, 원격 URL 검증, 기본 기록 디렉터리 생성이 필요할 때 사용합니다.
---

# BookJakBookJak Init

## Purpose

Configure the user's English reading study data repository for BookJakBookJak.

Use this skill when:

- `~/.bookjakbookjak/info.json` is missing or invalid
- `~/.bookjakbookjak/repo` is missing
- the configured data repository remote does not match the local checkout
- the user asks to set up, reset, or check the study data repository

## Storage

Use this internal storage root:

`~/.bookjakbookjak`

Use this configuration file:

`~/.bookjakbookjak/info.json`

Use this local checkout for study data:

`~/.bookjakbookjak/repo`

`info.json` must include:

```json
{
  "repo_url": "https://github.com/user/english-study-data.git",
  "repo_path": "/Users/name/.bookjakbookjak/repo",
  "default_branch": "main",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

Do not store document URLs, article text, study records, or review history in `info.json`.

## Setup Workflow

1. Check whether `~/.bookjakbookjak/info.json` exists and is valid JSON.
2. If it is missing or invalid, ask the user for the Git repository URL to use for study records.
3. Create `~/.bookjakbookjak`.
4. Clone the repository into `~/.bookjakbookjak/repo`.
5. Write `info.json` with `repo_url`, `repo_path`, `default_branch`, `created_at`, and `updated_at`.
6. If `~/.bookjakbookjak/repo` already exists, verify it is a Git repository.
7. Verify `git remote get-url origin` matches `info.json.repo_url`.
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
설정 파일: ~/.bookjakbookjak/info.json
데이터 저장소: ~/.bookjakbookjak/repo
```
