# fhdufhdu Plugins

Codex/Claude용 개인 플러그인 마켓플레이스입니다.

## 플러그인 목록

| 플러그인 | 설명 | README |
| --- | --- | --- |
| `bookjakbookjak` | 영어 리딩 설정, 문장별 학습, 복습 기록 관리 | [README](./plugins/bookjakbookjak/README.md) |
| `humanities-wiki` | 인문학 영상/에세이 링크, 문구, 성찰을 LLM wiki로 기록 | [README](./plugins/humanities-wiki/README.md) |

## Codex 설치

Git clone으로 직접 복사하지 말고 Codex 앱 또는 CLI의 플러그인/마켓플레이스 등록 기능을 사용하세요.
각 플러그인의 설치 명령과 사용법은 플러그인 목록의 README를 참고하세요.

### Codex 앱에서 등록

1. Codex 앱을 엽니다.
2. Plugins 화면에서 marketplace 또는 plugin source 추가 흐름을 엽니다.
3. source로 아래 저장소를 입력합니다.

```text
fhdufhdu/fhdufhdu-plugins
```

4. 설치할 플러그인을 선택하고 활성화합니다.

### Codex CLI에서 등록

```bash
codex plugin marketplace add fhdufhdu/fhdufhdu-plugins
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

마켓플레이스 등록 후 각 플러그인의 README를 참고해 플러그인을 설치합니다.
