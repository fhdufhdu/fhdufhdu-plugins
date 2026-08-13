# Feel English

한국어 번역어를 1:1로 암기하기보다 핵심 단어의 감각·이미지·쓰임을 문맥과 chunk로 익히는 Codex/Claude 플러그인입니다.

## 설치

먼저 루트 [README](../../README.md)를 참고해 플러그인 마켓플레이스를 등록하세요.

Codex CLI:

```bash
codex plugin add feel-english@fhdufhdu
```

Claude Code 세션:

```text
/plugin install feel-english@fhdufhdu
```

## 스킬

```text
feel-english:init
feel-english:study
```

- `init`: 사용자에게 학습 기록용 Git 저장소 URL을 묻고 `~/.fhdufhdu/feel-english`에 클론합니다.
- `study`: 핵심 100단어를 출발점으로 예문, chunk, 소리 반복, 문장 변형, 자기 문장, 상황 묘사, 회상 복습을 진행합니다.

## 학습 방식

하루 30~40분을 기준으로 다음 흐름을 사용합니다.

1. 전날 표현을 안 보고 회상
2. 신규 핵심 단어 2~5개를 예문으로 학습
3. 자주 함께 쓰이는 chunk를 소리 내어 반복
4. 주어·시제·목적어를 바꾸어 문장 변형
5. 자기 상황에 맞는 문장 생성
6. 일상 상황을 쉬운 영어로 바로 묘사
7. 마무리 회상과 1/4/7/30일 복습 기록

Tier 1은 `get`, `take`, `make`, `go`, `come`, `put`, `keep`, `give`, `bring`, `turn`처럼 회화에서 자주 쓰이고 파급력이 큰 단어부터 시작합니다. 알파벳순으로 진행하지 않습니다.

Oxford 3000에서 추출한 학습 목록은 [Tier 인덱스](./skills/study/references/tiers.md)에서 확인할 수 있습니다. Tier 1은 누적 100개, Tier 2는 300개, Tier 3은 1,000개입니다.

## 저장 위치

설정 파일:

```text
~/.fhdufhdu/config/feel-english.json
```

학습 기록 저장소:

```text
~/.fhdufhdu/feel-english
```

저장소 안에는 `sessions/`, `words/`, `reviews/`, `progress/`, `persistent/`를 두어 세션과 누적 학습 상태를 관리합니다.
