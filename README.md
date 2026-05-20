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
plugins/english-reading-study/skills/english-reading-study
```

포함 파일:

- `SKILL.md`
- `references/record-schema.md`

## 내부 저장 위치

스킬은 실행 설정을 아래 파일에 저장합니다.

```text
~/.bookjakbookjak/info.json
```

사용자의 실제 학습 데이터 저장소는 아래 위치에 클론합니다.

```text
~/.bookjakbookjak/repo
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
