# Feel English 학습 기록 스키마

학습 기록과 설명은 한국어로 작성하되, 경로명·파일명·frontmatter 키·JSON 키는 영어로 유지한다. 단어와 chunk, 예문, 사용자가 만든 영어 문장은 그대로 저장한다.

## 로컬 설정

```text
~/.fhdufhdu/config/feel-english.json
~/.fhdufhdu/feel-english
```

```json
{
  "repo_url": "https://github.com/user/feel-english-data.git",
  "repo_path": "/Users/name/.fhdufhdu/feel-english",
  "default_branch": "main",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

## 세션 기록

경로: `sessions/YYYY/YYYY-MM-DD.md`

```markdown
---
type: feel-english-session
date: YYYY-MM-DD
duration_minutes: 35
new_words: [get, take]
reviewed_words: [make]
status: completed
review_offsets: [1, 4, 7, 30]
---

# Feel English - YYYY-MM-DD

## 워밍업 회상

- 프롬프트:
- 사용자 답:
- 결과:

## get

핵심 이미지:

오늘의 chunk:
- get ready
- get better

사용자가 만든 문장:
- 원문:
- 수정문:
- 피드백:

상황 묘사:
- 상황:
- 사용자 표현:
- 제안 표현:

마무리 회상:
- 결과:
- 약점:
- 다음 노출:
```

같은 날 여러 세션이면 `YYYY-MM-DD-02.md`처럼 순번을 붙인다.

## 단어 누적 기록

경로: `words/<word>.md`

```markdown
---
type: word-record
word: get
tier: 1
status: learning
first_seen: YYYY-MM-DD
last_seen: YYYY-MM-DD
successful_recall_days: 0
---

# get

## 핵심 이미지

## 패턴과 chunk

### get + place
- get home

### get + adjective
- get tired
- get better

## 자기 문장

## 혼동한 점

## 노출 기록
- YYYY-MM-DD: first / partial / recalled / produced
```

`status`는 `new`, `learning`, `familiar`, `usable`을 사용한다. 한국어 뜻 목록을 누적하지 말고 패턴과 사용자 문장을 누적한다.

## 복습 기록

경로: `reviews/YYYY/YYYY-MM-DD.md`

```markdown
---
type: feel-english-review
date: YYYY-MM-DD
offsets: [1, 4, 7, 30]
---

# 복습 - YYYY-MM-DD

## get ready
- source_session: sessions/YYYY/YYYY-MM-DD.md
- prompt: 외출하기 전 준비 중인 상황
- user_answer:
- result: correct / partial / missed
- feedback:
- next_review:
```

## 전체 진도

경로: `progress/state.json`

```json
{
  "updated_at": "YYYY-MM-DD",
  "current_tier": 1,
  "queue": ["get", "take", "make"],
  "learning": ["go"],
  "familiar": [],
  "usable": [],
  "next_session": {
    "new_word_limit": 3,
    "due_words": ["get"]
  }
}
```

진도 JSON은 편의상 캐시이다. 상세 사실은 각 세션과 단어 기록을 우선한다.

## 장기 약점

경로: `persistent/weak-items.jsonl`

```json
{"id":"P001","created_at":"YYYY-MM-DD","updated_at":"YYYY-MM-DD","status":"active","word":"get","chunk":"get + adjective","prompt":"상태가 변하는 상황을 get으로 표현","issue":"get을 '얻다'로만 해석함","miss_count":2,"success_count":0,"last_seen":"YYYY-MM-DD","next_exposure":"YYYY-MM-DD","source_sessions":["sessions/YYYY/YYYY-MM-DD.md"]}
```

`status`는 `active`, `watch`, `retired`를 사용한다. 서로 다른 날 3회 성공하면 `watch`로, 나중 복습에서도 생산하면 `retired`로 바꿀 수 있다.

## 복습 대상 찾기

현재 날짜에서 1, 4, 7, 30일 전의 `sessions/`를 확인한다. 모든 예문을 다시 읽지 말고 다음을 우선한다.

1. 회상하지 못한 chunk
2. 이해했지만 직접 생산하지 못한 패턴
3. 사용자의 일상에 자주 쓸 수 있는 문장
4. active 장기 약점

복습 후 해당 단어 기록, 당일 복습 기록, 진도 JSON, 장기 약점을 함께 갱신한다.
