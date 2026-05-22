# Humanities Wiki

인문학 영상, 에세이, 의미 깊었던 문구, 개인 성찰을 LLM이 관리하는 개인 wiki로 정리하는 Codex/Claude 플러그인입니다.

이 플러그인은 Andrej Karpathy의 LLM wiki 패턴을 따릅니다. 원본 링크와 출처 메타데이터는 보존하고, LLM은 별도 Git 저장소 안에서 요약, 개념 페이지, 인물/작품/주제 페이지, `index.md`, `log.md`를 지속적으로 갱신합니다.

## 설치

먼저 루트 [README](../../README.md)를 참고해 플러그인 마켓플레이스를 등록하세요.

Codex CLI:

```bash
codex plugin add humanities-wiki@fhdufhdu
```

Claude Code 세션:

```text
/plugin install humanities-wiki@fhdufhdu
```

## 스킬

```text
humanities-wiki:init
humanities-wiki:capture
```

- `init`: `~/.humanities-wiki/info.json`을 만들고 기록용 Git 저장소를 `~/.humanities-wiki/repo`에 설정합니다.
- `capture`: 사용자가 제공한 인문학 영상/에세이 링크와 의미 깊었던 문구를 정리하고, LLM wiki를 갱신합니다. 설정이 없으면 먼저 `humanities-wiki:init`을 사용합니다.

## 내부 저장 위치

설정 파일:

```text
~/.humanities-wiki/info.json
```

기록 저장소 체크아웃:

```text
~/.humanities-wiki/repo
```

## 기록 구조

사용자가 지정한 저장소 안에는 아래 구조로 기록합니다.

- `raw/`: 변경하지 않는 원천 자료 메타데이터와 짧은 발췌
- `sources/`: 링크별 요약, 맥락, 저작권 메모
- `quotes/`: 의미 깊었던 문구와 사용자 해석
- `reflections/`: 개인 성찰과 변화의 방향
- `wiki/`: LLM이 유지하는 개념, 인물, 작품, 주제 페이지
- `index.md`: wiki 전체 색인
- `log.md`: ingest, query, lint 작업 이력
- `AGENTS.md`: 해당 데이터 저장소에서 따를 wiki 운영 규칙

기록과 설명은 한국어로 작성합니다. 경로명, YAML frontmatter 키, JSON 키는 도구 호환성을 위해 영어를 유지합니다.
