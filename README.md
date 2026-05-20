# fhdufhdu Plugins

Codex/Claude용 개인 플러그인 마켓플레이스입니다.

현재 포함된 플러그인:

- `bookjakbookjak`: 영어 리딩 학습 데이터 저장소 설정, 문장별 학습, 복습 기록 관리

실제 학습 데이터는 별도 저장소에 저장합니다.

- 플러그인 마켓플레이스 저장소: `https://github.com/fhdufhdu/fhdufhdu-plugins`
- 학습 데이터 저장소: `https://github.com/fhdufhdu/book-jak-book-jak-data`

## Codex 설치

Git clone으로 직접 복사하지 말고 Codex 앱 또는 CLI의 플러그인/마켓플레이스 등록 기능을 사용하세요.

### Codex 앱에서 등록

1. Codex 앱을 엽니다.
2. Plugins 화면에서 marketplace 또는 plugin source 추가 흐름을 엽니다.
3. source로 아래 저장소를 입력합니다.

```text
fhdufhdu/fhdufhdu-plugins
```

4. `bookjakbookjak` 플러그인을 설치하고 활성화합니다.

### Codex CLI에서 등록

```bash
codex plugin marketplace add fhdufhdu/fhdufhdu-plugins
codex plugin add bookjakbookjak@fhdufhdu
```

마켓플레이스를 갱신하려면 아래 명령을 사용합니다.

```bash
codex plugin marketplace upgrade fhdufhdu
```

## Claude Code 설치

터미널에서 아래 명령을 실행합니다.

```bash
claude plugin marketplace add fhdufhdu/fhdufhdu-plugins
```

Claude Code 세션 안에서는 아래 명령을 사용할 수 있습니다.

```text
/plugin marketplace add fhdufhdu/fhdufhdu-plugins
```

마켓플레이스 등록 후 플러그인을 설치합니다.

```text
/plugin install bookjakbookjak@fhdufhdu
```

## BookJakBookJak 스킬

```text
bookjakbookjak:init
bookjakbookjak:study
```

- `init`: `~/.bookjakbookjak/info.json`을 만들고 데이터 Git 저장소를 `~/.bookjakbookjak/repo`에 설정합니다.
- `study`: 영어 리딩 학습과 복습을 진행합니다. 저장소 설정이 없으면 먼저 `bookjakbookjak:init`을 사용합니다.

## 내부 저장 위치

설정 파일:

```text
~/.bookjakbookjak/info.json
```

데이터 저장소 체크아웃:

```text
~/.bookjakbookjak/repo
```

처음 사용할 때 `bookjakbookjak:init`은 학습 기록을 저장할 Git 저장소 URL을 사용자에게 물어봅니다. 이 프로젝트의 기본 데이터 저장소는 아래 URL입니다.

```text
https://github.com/fhdufhdu/book-jak-book-jak-data.git
```

## 학습 데이터 구조

사용자가 지정한 학습 데이터 저장소 안에는 아래 구조로 기록합니다.

- `daily/`: 날짜별 문장 학습 기록
- `reviews/`: 복습 세션 요약
- `cards/`: 재사용 가능한 복습 카드(JSONL)
- `sources/`: 전체 원문을 제외한 출처 메타데이터
- `persistent/`: 계속 외우지 못하는 장기 미숙 항목

학습 기록, 복습 기록, 문서 설명은 한국어로 작성합니다. 경로명, YAML frontmatter 키, JSON 키는 도구 호환성을 위해 영어를 유지합니다.
