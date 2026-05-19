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

### Codex에 설치

저장소를 먼저 클론합니다.

```bash
git clone https://github.com/fhdufhdu/eng-reading-study.git
cd eng-reading-study
```

프로젝트 단위로 사용할 때는 이 저장소의 marketplace 파일을 그대로 사용합니다.

```text
.agents/plugins/marketplace.json
```

Codex가 이 저장소를 작업공간으로 열면 marketplace가 `./plugins/english-reading-study` 플러그인을 가리킵니다.

사용자 전역에서 쓰고 싶다면 플러그인을 고정 위치에 두고 사용자 marketplace에 등록합니다.

```bash
mkdir -p ~/plugins ~/.agents/plugins
cp -R plugins/english-reading-study ~/plugins/english-reading-study
```

그 다음 `~/.agents/plugins/marketplace.json`에 아래 항목을 추가합니다.

```json
{
  "name": "eng-reading-study-local",
  "interface": {
    "displayName": "English Reading Study"
  },
  "plugins": [
    {
      "name": "english-reading-study",
      "source": {
        "source": "local",
        "path": "./plugins/english-reading-study"
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

이미 사용자 marketplace 파일이 있다면 `plugins` 배열에 `english-reading-study` 항목만 추가합니다.

### Codex 스킬만 설치

플러그인 전체가 아니라 스킬만 쓰고 싶다면 스킬 폴더를 Codex 스킬 위치에 복사합니다.

```bash
mkdir -p ~/.codex/skills
cp -R plugins/english-reading-study/skills/english-reading-study ~/.codex/skills/english-reading-study
```

이후 Codex에서 아래처럼 요청하면 스킬이 트리거됩니다.

```text
이 URL로 영어공부 시작해줘: https://example.com/article
```

## Claude 플러그인

같은 플러그인 폴더에 Claude용 manifest가 있습니다.

```text
plugins/english-reading-study/.claude-plugin/plugin.json
```

Claude marketplace 파일은 저장소 루트에 있습니다.

```text
.claude-plugin/marketplace.json
```

### Claude에 설치

Claude Code marketplace로 추가한 뒤 설치합니다.

```bash
claude plugin marketplace add fhdufhdu/eng-reading-study
claude plugin marketplace update
claude plugin install english-reading-study@eng-reading-study
```

설치 확인:

```bash
claude plugin list
claude plugin details english-reading-study
```

저장소를 클론한 뒤 임시로 로컬 테스트만 할 수도 있습니다.

```bash
claude --plugin-dir ./plugins/english-reading-study
```

이후 namespaced skill을 사용합니다.

```text
/english-reading-study:english-reading-study
```

### Claude 스킬만 설치

Claude 플러그인 설치 없이 스킬 파일만 직접 배치하려면 Claude 설정의 skills 디렉터리에 복사합니다.

```bash
mkdir -p ~/.claude/skills
cp -R plugins/english-reading-study/skills/english-reading-study ~/.claude/skills/english-reading-study
```

플러그인으로 설치한 경우에는 위 수동 복사가 필요 없습니다.

## 학습 시작 예시

```text
이 URL로 영어공부 시작해줘: https://example.com/article
```
