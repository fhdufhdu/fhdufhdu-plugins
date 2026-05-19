# 영어 리딩 학습 기록 스키마

영구 보관할 학습 기록은 아래 형식을 사용한다. 기록은 간결하고 나중에 다시 복습하기 쉽게 작성한다.

문서 본문, 제목, 설명, 피드백, 복습 메모는 한국어로 작성한다. 단, 경로명, 파일명, YAML frontmatter 키, JSON 키는 도구 호환성을 위해 영어를 유지한다.

## 내부 설정

경로:

`~/.english-reading-study/info.json`

스킬은 사용자에게 학습 기록을 저장할 Git 저장소 URL을 받은 뒤, 해당 저장소를 `~/.english-reading-study/repo`에 클론하고 이 파일을 생성해야 한다.

스키마:

```json
{
  "repo_url": "https://github.com/user/english-study-data.git",
  "repo_path": "/Users/name/.english-reading-study/repo",
  "default_branch": "main",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

저장소 설정이 바뀌면 `updated_at`을 갱신한다. `info.json`에는 문서 URL, 원문, 학습 이력을 저장하지 않는다. 그런 내용은 클론된 저장소 안에 기록한다.

## 일일 학습 기록

경로:

`daily/YYYY/YYYY-MM-DD-slug.md`

템플릿:

```markdown
---
type: daily-study
date: YYYY-MM-DD
title: "문서 제목"
url: "https://example.com/article"
source: "출처 또는 사이트명"
status: completed
difficulty: intermediate
review_offsets: [1, 4, 7, 30]
---

# YYYY-MM-DD - 문서 제목

## 메타데이터

- URL:
- 출처:
- 가져온 시각:
- 학습 범위:
- 상태:

## 문장별 학습 기록

### S001

원문 발췌:
> 학습에 필요한 짧은 문장 또는 최소 발췌만 저장한다.

사용자 해석:

추천 해석:

피드백:
- 판정:
- 핵심 포인트:
- 약점:
- 복습 우선순위:

기억할 항목:
- 단어:
- 숙어/표현:
- 문법/용법:

복습 기록:
- YYYY-MM-DD: 최초 학습
```

## 복습 요약

경로:

`reviews/YYYY/YYYY-MM-DD.md`

템플릿:

```markdown
---
type: review-summary
date: YYYY-MM-DD
offsets: [1, 4, 7, 30]
---

# 복습 요약 - YYYY-MM-DD

## 복습 대상

- daily/YYYY/YYYY-MM-DD-slug.md: 1일차 복습

## 결과

### daily/YYYY/YYYY-MM-DD-slug.md / S001

문제:

사용자 답변:

피드백:
- 판정:
- 아직 약한 부분:
- 나아진 부분:
- 다음 복습 우선순위:
```

## 복습 카드

경로:

`cards/YYYY/YYYY-MM-DD-slug.jsonl`

한 줄에 JSON 객체 하나씩 작성한다. JSON 키는 영어로 유지하고 값은 필요한 경우 한국어로 작성한다.

```json
{"id":"C001","date":"YYYY-MM-DD","source_record":"daily/YYYY/YYYY-MM-DD-slug.md","sentence_id":"S001","kind":"sentence","front":"짧은 원문 발췌","back":"추천 한국어 해석과 핵심 포인트","weak_points":["절 구조"],"priority":"high","review_dates":["YYYY-MM-DD","YYYY-MM-DD","YYYY-MM-DD","YYYY-MM-DD"],"history":[{"date":"YYYY-MM-DD","result":"최초 학습"}]}
```

카드 종류:

- sentence
- vocabulary
- idiom
- grammar
- usage
- weak-point

우선순위:

- high: 틀렸거나 구조적으로 중요한 항목
- medium: 부분적으로 맞았거나 유용한 표현
- low: 맞았지만 유지할 가치가 있는 항목

## 출처 메타데이터

경로:

`sources/YYYY/YYYY-MM-DD-slug.md`

템플릿:

```markdown
---
type: source
date: YYYY-MM-DD
title: "문서 제목"
url: "https://example.com/article"
source: "출처 또는 사이트명"
copyright_note: "전체 원문은 저장하지 않고, 학습에 필요한 짧은 발췌만 보관한다."
---

# 출처 - 문서 제목

## 메모

- 가져오기 메모:
- 선택한 학습 범위:
- 제외한 내용:
```

## 복습 대상 찾기

`TODAY` 기준으로 아래 날짜의 기록을 확인한다.

- TODAY - 1일
- TODAY - 4일
- TODAY - 7일
- TODAY - 30일

우선 `cards/` 파일을 사용한다. 카드 파일이 없으면 해당 날짜의 `daily/` 기록을 사용한다.

복습을 마치면 아래를 갱신한다.

1. 관련 일일 기록의 `복습 기록`.
2. 해당 카드 라인의 `history`.
3. 당일 복습 요약 파일.

전체 원문은 저장하지 않는다. 문장별 피드백에 필요한 짧은 발췌만 저장한다.
