# Skill/Data Repository Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the English reading study project into a clean skill/plugin repository and a separate data repository, with no study data left in the skill repository history.

**Architecture:** The data repository receives the current study-data snapshot as its first commit. The skill repository gains Codex and Claude Code plugin/marketplace metadata plus README installation instructions, then rewrites Git history to remove all data paths. Distribution uses Codex app/CLI and Claude Code marketplace registration, not manual repository cloning into skill directories.

**Tech Stack:** Git, temporarily installed `git-filter-repo`, Codex CLI plugin marketplace commands, Claude Code plugin metadata, JSON manifests, Markdown documentation.

---

## File Structure

Create or modify these files in `/Users/fhdufhdu/project/book-jak-book-jak`:

- Modify: `README.md` — user-facing install, update, data-repo, and marketplace registration instructions.
- Create: `.codex-plugin/plugin.json` — Codex plugin manifest for the root plugin.
- Create: `.agents/plugins/marketplace.json` — Codex marketplace manifest pointing to this root plugin.
- Create: `.claude-plugin/plugin.json` — Claude Code plugin manifest for the root plugin.
- Create: `.claude-plugin/marketplace.json` — Claude Code marketplace manifest named `book-jak-book-jak`.
- Existing: `skills/english-reading-study/SKILL.md` — keep as the shared skill body for Codex and Claude.
- Existing: `skills/english-reading-study/references/record-schema.md` — keep as shared skill reference documentation.

Move/copy these data directories from `/Users/fhdufhdu/project/book-jak-book-jak` into `/Users/fhdufhdu/project/book-jak-book-jak-data`:

- `daily/`
- `reviews/`
- `cards/`
- `sources/`
- `persistent/`

Remove these data directories from the skill repository working tree and history:

- `daily/`
- `reviews/`
- `cards/`
- `sources/`
- `persistent/`

---

### Task 1: Preflight State Check

**Files:**
- Inspect: `/Users/fhdufhdu/project/book-jak-book-jak`
- Inspect: `/Users/fhdufhdu/project/book-jak-book-jak-data`

- [ ] **Step 1: Confirm both repositories and remotes**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
git status --short
git branch --show-current
git remote -v

cd /Users/fhdufhdu/project/book-jak-book-jak-data
git status --short
git branch --show-current
git remote -v
```

Expected:

```text
book-jak-book-jak: clean or only expected plan/docs changes
book-jak-book-jak branch: main
book-jak-book-jak remote: https://github.com/fhdufhdu/book-jak-book-jak.git
book-jak-book-jak-data branch: main
book-jak-book-jak-data remote: https://github.com/fhdufhdu/book-jak-book-jak-data.git
```

- [ ] **Step 2: Confirm required source data exists**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
find daily reviews cards sources persistent -maxdepth 3 -type f | sort
```

Expected: output includes the existing 2026 study files and `persistent/weak-items.jsonl`.

- [ ] **Step 3: Confirm data repository is empty or safe to populate**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak-data
find . -maxdepth 3 -type f -not -path './.git/*' | sort
git log --oneline -1
```

Expected:

```text
No non-.git files.
git log may fail with: fatal: your current branch 'main' does not have any commits yet
```

If non-.git files exist, inspect them before continuing and preserve user-created files.

---

### Task 2: Populate Data Repository Snapshot

**Files:**
- Copy to data repo: `daily/`, `reviews/`, `cards/`, `sources/`, `persistent/`
- Commit in: `/Users/fhdufhdu/project/book-jak-book-jak-data`

- [ ] **Step 1: Copy current data snapshot**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
rsync -a daily reviews cards sources persistent /Users/fhdufhdu/project/book-jak-book-jak-data/
```

Expected: no output on success.

- [ ] **Step 2: Verify copied data layout**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak-data
find daily reviews cards sources persistent -maxdepth 3 -type f | sort
```

Expected:

```text
cards/2026/2026-05-19-anthropic-acquires-stainless.jsonl
cards/2026/2026-05-20-i-am-not-a-software-engineer.jsonl
daily/2026/2026-05-19-anthropic-acquires-stainless.md
daily/2026/2026-05-20-i-am-not-a-software-engineer.md
persistent/weak-items.jsonl
reviews/2026/2026-05-19.md
reviews/2026/2026-05-20.md
sources/2026/2026-05-19-anthropic-acquires-stainless.md
sources/2026/2026-05-20-i-am-not-a-software-engineer.md
```

- [ ] **Step 3: Commit data snapshot**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak-data
git add daily reviews cards sources persistent
git commit -m "Initialize English study data"
```

Expected: commit succeeds and reports the copied files.

- [ ] **Step 4: Push data repository**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak-data
git push -u origin main
```

Expected: push succeeds. If authentication fails, leave the local commit in place and report this exact command for the user to run.

---

### Task 3: Add Codex and Claude Plugin Metadata

**Files:**
- Create: `/Users/fhdufhdu/project/book-jak-book-jak/.codex-plugin/plugin.json`
- Create: `/Users/fhdufhdu/project/book-jak-book-jak/.agents/plugins/marketplace.json`
- Create: `/Users/fhdufhdu/project/book-jak-book-jak/.claude-plugin/plugin.json`
- Create: `/Users/fhdufhdu/project/book-jak-book-jak/.claude-plugin/marketplace.json`

- [ ] **Step 1: Create Codex plugin manifest**

Create `/Users/fhdufhdu/project/book-jak-book-jak/.codex-plugin/plugin.json` with:

```json
{
  "name": "english-reading-study",
  "version": "1.0.0",
  "description": "Guide English reading sessions, capture sentence-level feedback, and save study records to a user-configured data repository.",
  "author": {
    "name": "fhdufhdu",
    "url": "https://github.com/fhdufhdu"
  },
  "homepage": "https://github.com/fhdufhdu/book-jak-book-jak",
  "repository": "https://github.com/fhdufhdu/book-jak-book-jak",
  "license": "MIT",
  "keywords": [
    "english",
    "reading",
    "study",
    "review"
  ],
  "skills": "./skills/",
  "interface": {
    "displayName": "English Reading Study",
    "shortDescription": "Sentence-by-sentence English reading practice with durable review records.",
    "longDescription": "A Codex skill for guided English reading practice. It asks the user to translate one sentence at a time, gives concise Korean feedback, and writes daily study records, review cards, source metadata, and persistent weak items to a separate user-configured data repository.",
    "developerName": "fhdufhdu",
    "category": "Productivity",
    "capabilities": [
      "Interactive",
      "Write"
    ],
    "websiteURL": "https://github.com/fhdufhdu/book-jak-book-jak",
    "defaultPrompt": [
      "이 URL로 영어공부 시작해줘.",
      "오늘 복습할 영어 학습 기록을 확인해줘.",
      "영어 리딩 학습 데이터 저장소를 설정해줘."
    ],
    "brandColor": "#2563EB"
  }
}
```

- [ ] **Step 2: Create Codex marketplace manifest**

Create `/Users/fhdufhdu/project/book-jak-book-jak/.agents/plugins/marketplace.json` with:

```json
{
  "name": "book-jak-book-jak",
  "interface": {
    "displayName": "Book Jak Book Jak"
  },
  "plugins": [
    {
      "name": "english-reading-study",
      "source": {
        "source": "local",
        "path": "./"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity"
    }
  ]
}
```

- [ ] **Step 3: Create Claude Code plugin manifest**

Create `/Users/fhdufhdu/project/book-jak-book-jak/.claude-plugin/plugin.json` with:

```json
{
  "name": "english-reading-study",
  "description": "Guide English reading sessions, capture sentence-level feedback, and save study records to a user-configured data repository.",
  "version": "1.0.0",
  "author": {
    "name": "fhdufhdu"
  },
  "homepage": "https://github.com/fhdufhdu/book-jak-book-jak",
  "repository": "https://github.com/fhdufhdu/book-jak-book-jak",
  "license": "MIT"
}
```

- [ ] **Step 4: Create Claude Code marketplace manifest**

Create `/Users/fhdufhdu/project/book-jak-book-jak/.claude-plugin/marketplace.json` with:

```json
{
  "name": "book-jak-book-jak",
  "owner": {
    "name": "fhdufhdu"
  },
  "description": "English reading study plugins and skills.",
  "plugins": [
    {
      "name": "english-reading-study",
      "source": "./",
      "displayName": "English Reading Study",
      "description": "Sentence-by-sentence English reading practice with Korean feedback and durable review records.",
      "version": "1.0.0",
      "author": {
        "name": "fhdufhdu"
      },
      "homepage": "https://github.com/fhdufhdu/book-jak-book-jak",
      "repository": "https://github.com/fhdufhdu/book-jak-book-jak",
      "license": "MIT",
      "category": "productivity",
      "tags": [
        "english",
        "reading",
        "study",
        "review"
      ]
    }
  ]
}
```

- [ ] **Step 5: Parse JSON manifests**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
python3 -m json.tool .codex-plugin/plugin.json >/dev/null
python3 -m json.tool .agents/plugins/marketplace.json >/dev/null
python3 -m json.tool .claude-plugin/plugin.json >/dev/null
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null
```

Expected: no output on success.

---

### Task 4: Update README Installation and Data Instructions

**Files:**
- Modify: `/Users/fhdufhdu/project/book-jak-book-jak/README.md`

- [ ] **Step 1: Replace README with plugin-first instructions**

Replace `/Users/fhdufhdu/project/book-jak-book-jak/README.md` with:

```markdown
# 영어 리딩 학습 스킬

영어 문서를 문장 단위로 읽고 해석하면서 학습 기록과 복습 기록을 남기는 개인용 Codex/Claude 스킬입니다.

이 저장소는 스킬과 플러그인 배포용 저장소입니다. 실제 학습 데이터는 별도 저장소에 저장합니다.

- 스킬/플러그인 저장소: `https://github.com/fhdufhdu/book-jak-book-jak`
- 학습 데이터 저장소: `https://github.com/fhdufhdu/book-jak-book-jak-data`

## 설치 방법

Git clone으로 스킬 폴더에 직접 복사하지 말고, Codex 앱 또는 CLI, Claude Code의 플러그인/마켓플레이스 등록 기능을 사용하세요.

### Codex 앱에서 등록

1. Codex 앱을 엽니다.
2. Plugins 화면에서 marketplace 또는 plugin source 추가 흐름을 엽니다.
3. source로 아래 저장소를 입력합니다.

```text
fhdufhdu/book-jak-book-jak
```

4. `English Reading Study` 또는 `english-reading-study` 플러그인/스킬을 활성화합니다.

### Codex CLI에서 등록

터미널에서 아래 명령을 실행합니다.

```bash
codex plugin marketplace add fhdufhdu/book-jak-book-jak
```

마켓플레이스를 갱신하려면 아래 명령을 사용합니다.

```bash
codex plugin marketplace upgrade book-jak-book-jak
```

Codex CLI 세션 안에서 플러그인/마켓플레이스 명령을 사용할 수도 있습니다.

### Claude Code에서 등록

터미널에서 아래 명령을 실행합니다.

```bash
claude plugin marketplace add fhdufhdu/book-jak-book-jak
```

Claude Code 세션 안에서는 아래 명령을 사용할 수 있습니다.

```text
/plugin marketplace add fhdufhdu/book-jak-book-jak
```

마켓플레이스 등록 후 플러그인을 설치합니다.

```text
/plugin install english-reading-study@book-jak-book-jak
```

## 스킬 위치

```text
skills/english-reading-study
```

포함 파일:

- `SKILL.md`
- `references/record-schema.md`

## 내부 저장 위치

스킬은 실행 설정을 아래 파일에 저장합니다.

```text
~/.english-reading-study/info.json
```

사용자의 실제 학습 데이터 저장소는 아래 위치에 클론합니다.

```text
~/.english-reading-study/repo
```

처음 사용할 때 스킬은 학습 기록을 저장할 Git 저장소 URL을 사용자에게 물어봅니다. 이 프로젝트의 기본 데이터 저장소는 아래 URL입니다.

```text
https://github.com/fhdufhdu/book-jak-book-jak-data.git
```

이후 스킬은 해당 저장소를 클론하고, 저장소 URL과 로컬 클론 경로를 `info.json`에 저장합니다.

## 학습 데이터 구조

사용자가 지정한 학습 데이터 저장소 안에는 아래 구조로 기록합니다.

- `daily/`: 날짜별 문장 학습 기록
- `reviews/`: 복습 세션 요약
- `cards/`: 재사용 가능한 복습 카드(JSONL)
- `sources/`: 전체 원문을 제외한 출처 메타데이터
- `persistent/`: 계속 외우지 못하는 장기 미숙 항목

학습 기록, 복습 기록, 문서 설명은 한국어로 작성합니다. 경로명, YAML frontmatter 키, JSON 키는 도구 호환성을 위해 영어를 유지합니다.

## 학습 시작 예시

```text
이 URL로 영어공부 시작해줘: https://example.com/article
```
```

- [ ] **Step 2: Confirm README no longer recommends clone-based skill installation**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
rg -n "tree/main/skills|Git clone으로 스킬 폴더에 직접" README.md
```

Expected:

```text
README.md contains the warning not to copy by Git clone.
README.md does not contain the old github.com/.../tree/main/skills install prompt.
```

---

### Task 5: Remove Data Directories from Skill Repository Working Tree

**Files:**
- Delete from skill repo working tree: `daily/`, `reviews/`, `cards/`, `sources/`, `persistent/`

- [ ] **Step 1: Remove data directories from the skill repository**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
rm -rf daily reviews cards sources persistent
```

Expected: no output on success.

- [ ] **Step 2: Confirm only skill/plugin/docs files remain**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
find . -maxdepth 4 -type f -not -path './.git/*' | sort
```

Expected: output includes `README.md`, plugin manifests, `skills/english-reading-study/SKILL.md`, `skills/english-reading-study/references/record-schema.md`, specs/plans docs, and no files under `daily/`, `reviews/`, `cards/`, `sources/`, or `persistent/`.

- [ ] **Step 3: Commit skill repository working-tree changes**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
git add README.md .codex-plugin .agents .claude-plugin skills docs
git add -u daily reviews cards sources persistent
git commit -m "Prepare skill plugin distribution"
```

Expected: commit succeeds and includes README, manifests, and removal of data directories.

---

### Task 6: Validate Plugin Metadata Minimally

**Files:**
- Validate: `.codex-plugin/plugin.json`
- Validate: `.agents/plugins/marketplace.json`
- Validate: `.claude-plugin/plugin.json`
- Validate: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Re-parse JSON after commit**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
python3 -m json.tool .codex-plugin/plugin.json >/dev/null
python3 -m json.tool .agents/plugins/marketplace.json >/dev/null
python3 -m json.tool .claude-plugin/plugin.json >/dev/null
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null
```

Expected: no output on success.

- [ ] **Step 2: Run Claude validation only if Claude CLI exists**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
if command -v claude >/dev/null 2>&1; then
  claude plugin validate .
else
  echo "claude CLI not installed; skipping claude plugin validate"
fi
```

Expected: either validation succeeds, or the skip message prints.

- [ ] **Step 3: Confirm Codex CLI marketplace command is available**

Run:

```bash
codex plugin marketplace add --help | sed -n '1,40p'
```

Expected: help output contains:

```text
Usage: codex plugin marketplace add [OPTIONS] <SOURCE>
```

---

### Task 7: Install `git-filter-repo` Temporarily

**Files:**
- Install tool outside the repository
- Record cleanup command for Task 10

- [ ] **Step 1: Check whether `git-filter-repo` is already available**

Run:

```bash
command -v git-filter-repo
git filter-repo --version
```

Expected: both commands succeed if already installed. If they fail, continue to Step 2.

- [ ] **Step 2: Install `git-filter-repo` only if missing**

Run:

```bash
if ! command -v git-filter-repo >/dev/null 2>&1; then
  python3 -m pip install --user git-filter-repo
fi
```

Expected: install succeeds.

- [ ] **Step 3: Confirm the installed command is usable**

Run:

```bash
command -v git-filter-repo
git filter-repo --version
```

Expected: both commands succeed.

If the command is still not available because the user install path is not on `PATH`, find the script path and use that full path for Task 8:

```bash
python3 -m site --user-base
find "$(python3 -m site --user-base)" -name git-filter-repo -type f
```

If installation fails, stop before rewriting history and report:

```text
git-filter-repo is required before rewriting history. Install it, then rerun Task 7.
```

---

### Task 8: Rewrite Skill Repository History to Remove Data

**Files:**
- Rewrite Git history in: `/Users/fhdufhdu/project/book-jak-book-jak`

- [ ] **Step 1: Save current remote URL before rewrite**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
git remote get-url origin > /tmp/book-jak-book-jak-origin-url.txt
cat /tmp/book-jak-book-jak-origin-url.txt
```

Expected:

```text
https://github.com/fhdufhdu/book-jak-book-jak.git
```

- [ ] **Step 2: Rewrite history**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
git filter-repo --force \
  --path daily/ \
  --path reviews/ \
  --path cards/ \
  --path sources/ \
  --path persistent/ \
  --invert-paths
```

Expected: `git filter-repo` completes successfully and rewrites commits.

- [ ] **Step 3: Restore origin remote if filter-repo removed it**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$(cat /tmp/book-jak-book-jak-origin-url.txt)"
fi
git remote -v
```

Expected: origin points to `https://github.com/fhdufhdu/book-jak-book-jak.git`.

- [ ] **Step 4: Verify data paths are absent from history**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
git log --all -- daily reviews cards sources persistent
```

Expected: no commits are printed.

- [ ] **Step 5: Verify data paths are absent from working tree**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
test ! -e daily
test ! -e reviews
test ! -e cards
test ! -e sources
test ! -e persistent
```

Expected: no output on success.

---

### Task 9: Push Repositories

**Files:**
- Push data repo: `/Users/fhdufhdu/project/book-jak-book-jak-data`
- Force-push skill repo: `/Users/fhdufhdu/project/book-jak-book-jak`

- [ ] **Step 1: Confirm data repository is pushed or push it**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak-data
git status --short
git push -u origin main
```

Expected: clean status and successful push. If it already says everything is up to date, that is acceptable.

- [ ] **Step 2: Force-push rewritten skill repository**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
git status --short
git push --force-with-lease origin main
```

Expected: clean status and successful forced update of `main`.

If authentication fails, report this exact command to run manually:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
git push --force-with-lease origin main
```

---

### Task 10: Remove Temporary `git-filter-repo` Installation

**Files:**
- Remove tool outside the repository if Task 7 installed it

- [ ] **Step 1: Uninstall the temporary Python package**

Run:

```bash
python3 -m pip uninstall -y git-filter-repo
```

Expected: uninstall succeeds if Task 7 installed the package. If the package was already installed before this task started, do not uninstall it.

- [ ] **Step 2: Confirm removal if it was installed temporarily**

Run:

```bash
command -v git-filter-repo || true
```

Expected: no path is printed if Task 7 installed it temporarily and uninstall removed it.

---

### Task 11: Final Smoke Checks

**Files:**
- Inspect: both repositories

- [ ] **Step 1: Confirm data repo has the snapshot**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak-data
find daily reviews cards sources persistent -maxdepth 3 -type f | sort
git status --short
```

Expected: data files are listed and Git status is clean.

- [ ] **Step 2: Confirm skill repo has no data paths**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
find . -maxdepth 3 -type d | sort
git status --short
git log --all -- daily reviews cards sources persistent
```

Expected: no top-level data directories, clean status, and no log output for the removed data paths.

- [ ] **Step 3: Confirm README includes app/CLI marketplace installation**

Run:

```bash
cd /Users/fhdufhdu/project/book-jak-book-jak
rg -n "Codex 앱|codex plugin marketplace add|Claude Code|claude plugin marketplace add|/plugin marketplace add|/plugin install" README.md
```

Expected: README contains all listed installation paths.

- [ ] **Step 4: Record completion notes**

In the final response, include:

```text
- Data repo initialized and pushed with current study-data snapshot.
- Skill repo plugin metadata and README updated.
- Skill repo history rewritten to remove data paths.
- Skill repo force-pushed with --force-with-lease.
- Minimal verification commands completed.
```

If any push or optional validation did not run, say exactly which command remains.
