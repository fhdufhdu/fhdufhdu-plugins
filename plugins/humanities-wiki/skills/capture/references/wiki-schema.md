# Humanities Wiki 기록 스키마

이 저장소는 Karpathy의 LLM wiki 패턴을 인문학 기록에 맞게 적용한다. 원천 자료는 보존하고, LLM은 별도의 wiki 계층을 계속 갱신한다.

## 핵심 계층

- `raw/`: 사용자가 제공한 원천 자료의 변경하지 않는 메타데이터, 짧은 발췌, transcript 위치 메모
- `raw/fulltext/`: 사용자가 저작권 위험 경고를 확인하고 명시적으로 선택한 경우에만 저장하는 원문, transcript, subtitles
- `sources/`: 링크별 요약, 맥락, 저작권 메모, 관련 wiki 페이지 목록
- `quotes/`: 사용자가 의미 깊게 느낀 문구와 그 이유
- `reflections/`: 개인 성찰, 변화의 방향, 남은 질문
- `wiki/`: LLM이 직접 유지하는 개념, 인물, 작품, 주제, 질문 페이지
- `index.md`: content-oriented catalog. wiki를 탐색하기 위한 최신 색인
- `log.md`: chronological log. ingest, query, lint 작업 이력
- `AGENTS.md`: 이 데이터 저장소에서 따라야 하는 운영 규칙

## 내부 설정

경로:

`~/.humanities-wiki/info.json`

스키마:

```json
{
  "repo_url": "https://github.com/user/humanities-wiki-data.git",
  "repo_path": "/Users/name/.humanities-wiki/repo",
  "default_branch": "main",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

`info.json`에는 링크, 문구, 성찰, wiki 내용을 저장하지 않는다.

## Source Record

경로:

`sources/YYYY/YYYY-MM-DD-slug.md`

템플릿:

```markdown
---
type: source
date: YYYY-MM-DD
title: "자료 제목"
url: "https://example.com"
creator: "창작자 또는 발행자"
medium: essay
language: ko
status: captured
fulltext_saved: false
fulltext_path: ""
copyright_note: "기본값은 전체 원문을 저장하지 않고, 요약과 필요한 짧은 발췌만 보관한다."
copyright_risk_note: ""
---

# 자료 제목

## 메타데이터

- URL:
- 창작자:
- 매체:
- 발행일:
- 가져온 시각:

## 요약

짧고 정확한 한국어 요약.

## 핵심 논지

- 

## 내게 닿은 지점

- 

## 관련 wiki 페이지

- [개념](../../wiki/concepts/example.md)

## 저작권 메모

기본값은 전체 원문을 저장하지 않는 것이다. 사용자가 명시적으로 원문/자막 저장을 선택한 경우, 저장소가 외부 공개되거나 공유될 때 저작권 문제가 생길 수 있음을 기록한다.
```

## Full Text Record

경로:

`raw/fulltext/YYYY/YYYY-MM-DD-slug.md`

이 파일은 캡처 전에 제시한 저장 옵션에서 사용자가 저작권 위험 경고를 확인한 뒤 원문, transcript, subtitles 저장을 명시적으로 선택한 경우에만 만든다. 공개 저장소에 저장하면 저작권 문제가 생길 수 있다는 경고를 source record에도 남긴다.

템플릿:

```markdown
---
type: fulltext
date: YYYY-MM-DD
source: "sources/YYYY/YYYY-MM-DD-slug.md"
url: "https://example.com"
storage_confirmed_by_user: true
copyright_risk_note: "저장소가 public이거나 외부 공유될 경우 원문/자막 저장은 저작권 문제가 될 수 있다."
---

# 원문 또는 자막 - 자료 제목

## 저장 경고

이 파일은 캡처 전에 사용자가 원문/자막 저장 옵션을 선택해서 저장했다. 저장소 공개 범위와 저작권 위험을 주기적으로 확인한다.

## 원문 기반 요약

전체 원문 또는 자막을 바탕으로 한 자세한 한국어 요약.

## 구간별 요약

긴 글이나 영상 transcript라면 시간대, 문단, 장면, 논지 전환 단위로 나누어 정리한다.

- 00:00-03:20 또는 1-5문단:

## 핵심 주장

- 

## 중요한 대목

원문 전체를 반복하지 말고, 나중에 다시 볼 필요가 있는 짧은 대목과 위치 단서만 남긴다.

- 

## wiki로 연결할 개념

- [개념명](../../wiki/concepts/slug.md)

## 이 자료가 만든 질문

- 

## 본문

원문, transcript, subtitles.
```

## Quote Record

경로:

`quotes/YYYY/YYYY-MM-DD-slug.md`

템플릿:

```markdown
---
type: quote-record
date: YYYY-MM-DD
source: "sources/YYYY/YYYY-MM-DD-slug.md"
---

# 문구 기록 - 자료 제목

## Q001

문구:
> 사용자가 의미 깊다고 전달한 짧은 문구

사용자 메모:

왜 남았는가:

연결되는 주제:
- 

다시 볼 질문:
- 
```

## Reflection Record

경로:

`reflections/YYYY/YYYY-MM-DD-slug.md`

템플릿:

```markdown
---
type: reflection
date: YYYY-MM-DD
sources:
  - "sources/YYYY/YYYY-MM-DD-slug.md"
---

# 성찰 - YYYY-MM-DD

## 오늘 흔들린 생각

## 내가 되고 싶은 방향

## 아직 대답하지 못한 질문

## 다음에 찾아볼 자료
```

## Wiki Pages

경로:

```text
wiki/concepts/slug.md
wiki/people/slug.md
wiki/works/slug.md
wiki/themes/slug.md
wiki/questions/slug.md
```

템플릿:

```markdown
---
type: wiki-page
category: concept
title: "개념명"
updated: YYYY-MM-DD
source_count: 1
---

# 개념명

## 요약

현재까지의 자료를 종합한 설명.

## 관련 자료

- [자료 제목](../../sources/YYYY/YYYY-MM-DD-slug.md)

## 연결된 생각

- 

## 긴장과 모순

- 새 자료가 기존 이해와 충돌하면 지우지 말고 여기에 기록한다.

## 남은 질문

- 
```

## index.md

`index.md`는 내용 중심 색인이다. 새 source ingest, query filing, lint 이후 항상 갱신한다.

```markdown
# Humanities Wiki Index

## Concepts

- [개념명](wiki/concepts/slug.md): 한 줄 요약. sources: 1

## People

## Works

## Themes

## Questions

## Sources

- [자료 제목](sources/YYYY/YYYY-MM-DD-slug.md): 한 줄 요약.
```

## log.md

`log.md`는 append-only에 가깝게 다룬다. 각 항목은 grep 가능한 prefix로 시작한다.

```markdown
# Humanities Wiki Log

## [YYYY-MM-DD] ingest | 자료 제목

- source: sources/YYYY/YYYY-MM-DD-slug.md
- touched: wiki/concepts/example.md, index.md
- note: 새로 생긴 질문 또는 기존 해석의 변화
```

작업 종류:

- `ingest`: 새 자료 반영
- `query`: 질문 답변을 wiki에 다시 저장
- `lint`: wiki 상태 점검과 정리

## 작성 원칙

기록은 한국어로 쓴다. 경로명, 파일명, YAML frontmatter 키, JSON 키는 영어로 유지한다.

문학적 과장을 피하고 구체적으로 쓴다. 좋은 기록은 "내가 좋아했다"에서 끝나지 않고, 어떤 문장이 왜 남았는지, 어떤 기존 믿음을 건드렸는지, 다음에 어떤 질문을 만들었는지까지 남긴다.
