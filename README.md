# 영어 리딩 학습

영어 문서를 문장 단위로 읽고 해석하면서 학습 기록과 복습 기록을 남기는 개인용 플러그인입니다.

## 내부 저장 위치

플러그인은 실행 설정을 아래 파일에 저장합니다.

```text
~/.english-reading-study/info.json
```

사용자의 실제 학습 데이터 저장소는 아래 위치에 클론합니다.

```text
~/.english-reading-study/repo
```

처음 사용할 때 스킬은 학습 기록을 저장할 Git 저장소 URL을 사용자에게 물어봅니다. 이후 해당 저장소를 클론하고, 저장소 URL과 로컬 클론 경로를 `info.json`에 저장합니다.

## 데이터 구조

- `~/.english-reading-study/repo/daily/`: 날짜별 문장 학습 기록
- `~/.english-reading-study/repo/reviews/`: 복습 세션 요약
- `~/.english-reading-study/repo/cards/`: 재사용 가능한 복습 카드(JSONL)
- `~/.english-reading-study/repo/sources/`: 전체 원문을 제외한 출처 메타데이터
- `plugins/english-reading-study/`: Codex와 Claude에서 사용할 플러그인 패키지

학습 기록, 복습 기록, 문서 설명은 한국어로 작성합니다. 경로명, YAML frontmatter 키, JSON 키는 도구 호환성을 위해 영어를 유지합니다.

## Codex 플러그인

플러그인 위치:

```text
plugins/english-reading-study
```

포함 파일:

- `.codex-plugin/plugin.json`
- `skills/english-reading-study/SKILL.md`
- `skills/english-reading-study/references/record-schema.md`

Codex marketplace 파일도 함께 포함되어 있습니다.

```text
.agents/plugins/marketplace.json
```

## Claude 플러그인

같은 플러그인 폴더에 Claude용 manifest가 있습니다.

```text
plugins/english-reading-study/.claude-plugin/plugin.json
```

저장소를 클론한 뒤 로컬 테스트:

```bash
claude --plugin-dir ./plugins/english-reading-study
```

이후 namespaced skill을 사용합니다.

```text
/english-reading-study:english-reading-study
```

## 학습 시작 예시

```text
이 URL로 영어공부 시작해줘: https://example.com/article
```
