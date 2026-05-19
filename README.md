# 영어 리딩 학습 스킬

영어 문서를 문장 단위로 읽고 해석하면서 학습 기록과 복습 기록을 남기는 개인용 Codex/Claude 스킬입니다.

## 설치 방법

Codex 또는 Claude에게 아래처럼 요청하면 됩니다.

```text
https://github.com/fhdufhdu/eng-reading-study/tree/main/skills/english-reading-study
여기 있는 영어 리딩 학습 스킬 설치해줘.
```

스킬 설치 후 Codex는 재시작해야 새 스킬을 인식할 수 있습니다.

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

처음 사용할 때 스킬은 학습 기록을 저장할 Git 저장소 URL을 사용자에게 물어봅니다. 이후 해당 저장소를 클론하고, 저장소 URL과 로컬 클론 경로를 `info.json`에 저장합니다.

## 학습 데이터 구조

사용자가 지정한 학습 데이터 저장소 안에는 아래 구조로 기록합니다.

- `daily/`: 날짜별 문장 학습 기록
- `reviews/`: 복습 세션 요약
- `cards/`: 재사용 가능한 복습 카드(JSONL)
- `sources/`: 전체 원문을 제외한 출처 메타데이터

학습 기록, 복습 기록, 문서 설명은 한국어로 작성합니다. 경로명, YAML frontmatter 키, JSON 키는 도구 호환성을 위해 영어를 유지합니다.

## 학습 시작 예시

```text
이 URL로 영어공부 시작해줘: https://example.com/article
```
