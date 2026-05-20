# BookJakBookJak

영어 리딩 학습과 복습을 진행하는 Codex/Claude 플러그인입니다.

## 설치

먼저 루트 [README](../../README.md)를 참고해 플러그인 마켓플레이스를 등록하세요.

Codex CLI:

```bash
codex plugin add bookjakbookjak@fhdufhdu
```

Claude Code 세션:

```text
/plugin install bookjakbookjak@fhdufhdu
```

## 스킬

```text
bookjakbookjak:init
bookjakbookjak:study
```

- `init`: `~/.bookjakbookjak/info.json`을 만들고 기록용 Git 저장소를 `~/.bookjakbookjak/repo`에 설정합니다.
- `study`: 영어 리딩 학습과 복습을 진행합니다. 저장소 설정이 없으면 먼저 `bookjakbookjak:init`을 사용합니다.

## 내부 저장 위치

설정 파일:

```text
~/.bookjakbookjak/info.json
```

기록 저장소 체크아웃:

```text
~/.bookjakbookjak/repo
```

처음 사용할 때 `bookjakbookjak:init`은 학습 기록을 저장할 Git 저장소 URL을 사용자에게 물어봅니다. 이 프로젝트의 기본 기록 저장소는 아래 URL입니다.

```text
https://github.com/fhdufhdu/book-jak-book-jak-data.git
```

## 기록 구조

사용자가 지정한 저장소 안에는 아래 구조로 기록합니다.

- `daily/`: 날짜별 문장 학습 기록
- `reviews/`: 복습 세션 요약
- `cards/`: 재사용 가능한 복습 카드(JSONL)
- `sources/`: 전체 원문을 제외한 출처 메타데이터
- `persistent/`: 계속 외우지 못하는 장기 미숙 항목

학습 기록, 복습 기록, 문서 설명은 한국어로 작성합니다. 경로명, YAML frontmatter 키, JSON 키는 도구 호환성을 위해 영어를 유지합니다.
