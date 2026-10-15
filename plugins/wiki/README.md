# Wiki

`wwiki`로 source 작성과 위키 컴파일을 관리하는 Codex/Claude 플러그인입니다.

## 설치

루트 [README](../../README.md)를 참고해 마켓플레이스를 등록한 뒤 설치합니다.

Codex CLI:

```bash
codex plugin add wiki@fhdufhdu
```

Claude Code 세션:

```text
/plugin install wiki@fhdufhdu
```

## 스킬

- `wiki:init`: 환경을 확인하고, 미구성 상태면 도구와 위키 저장소를 클론해 설치합니다. 최초 설치에서 일반 설치와 임베딩 설치 중 선택합니다. 임베딩 설치는 모델을 백그라운드에서 실행하고 준비 상태를 확인합니다.
- `wiki:wiki`: init으로 환경을 점검한 뒤 요청한 내용을 `sources/`에 기록하거나 기존 source를 읽어 `pages/`로 컴파일합니다. 원본과 출처를 보존하고 `INDEX.md`, 검색 인덱스, 컴파일 상태를 갱신합니다.

사용 예:

```text
위키 환경을 초기화해줘.
이 설계 결정을 위키 source로 기록해줘.
미컴파일 source를 위키로 컴파일해줘.
wwiki 업데이트를 확인하고 기존 설치 방식으로 업데이트해줘.
```

## 저장 위치

```text
~/.fhdufhdu-wiki/
  wwiki/       # fhdufhdu/wwiki 도구 저장소
  wiki/        # fhdufhdu/wiki 지식 저장소
  config.json  # 설치 방식과 설치한 커밋
```

일반 설치는 로컬 BM25 검색을 사용합니다. 임베딩 설치는 vector extra(torch 등)와 KURE 모델(현재 약 2.2GB)을 추가하고 `wwiki serve --detach`로 모델을 상주시킵니다. 실행 로그는 `~/.cache/wwiki/serve.log`에 있습니다.

이미 구성된 환경은 빠르게 점검하고 init을 종료합니다. 원격 업데이트는 최초 설정·복구 또는 명시적인 업데이트 요청에서 확인합니다. 업데이트는 로컬 수정을 보존하며 가능한 경우에만 fast-forward하고 선택한 설치 방식을 유지합니다. 위키 관리 파일 업그레이드는 변경 예정과 사용자 편집을 확인한 뒤 처리합니다.

두 GitHub 저장소에 접근할 수 있는 Git 인증이 필요합니다. 설치는 `git`, `uv`, wwiki가 요구하는 Python을 사용합니다. 플러그인 설치 자체는 도구·모델을 다운로드하거나 데몬을 실행하지 않으며 `wiki:init` 실행 시 구성합니다.
