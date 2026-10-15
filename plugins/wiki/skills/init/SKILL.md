---
name: init
description: 위키 관리 환경을 초기화하거나 점검합니다. ~/.fhdufhdu-wiki에 wwiki와 wiki를 클론하고, 일반 또는 임베딩 설치를 선택해 설치·복구하며 wwiki 업데이트 요청을 처리합니다.
---

# Wiki Init

## 경로와 상태

```text
~/.fhdufhdu-wiki/
  wwiki/       # https://github.com/fhdufhdu/wwiki.git — CLI 소스
  wiki/        # https://github.com/fhdufhdu/wiki.git — 지식 저장소
  config.json  # 설치 방식과 성공적으로 설치한 커밋
```

`config.json`에는 `install_mode`(`basic` 또는 `vector`), `installed_commit`, `updated_at`(ISO 8601)만 기록한다. 설치와 검증이 성공한 뒤 원자적으로 저장한다. API 키나 인증 정보는 저장하지 않는다.

## 0. 구성 확인과 빠른 종료

1. 설정과 두 경로를 확인한다. 두 경로가 각각 독립된 Git 저장소인지 확인하고 origin이 위 URL과 같은 저장소를 가리키는지 검사한다. HTTPS의 `.git` 유무와 같은 저장소의 SSH URL은 허용한다. 상위 저장소에 속한 일반 디렉터리를 정상 클론으로 간주하지 않는다.
2. `wwiki --help`가 성공하고 설치된 도구가 위 `wwiki/` 클론에서 설치됐는지 `uv tool list`와 도구 환경의 설치 메타데이터로 확인한다. `installed_commit`이 클론 HEAD와 같은지 확인한다. 임베딩 모드는 도구 환경에 vector 의존성이 있는지도 확인한다.
3. `wwiki check --wiki-root "$HOME/.fhdufhdu-wiki/wiki"`의 JSON에서 `up_to_date`를 확인한다. `PROJECT.md`, `INDEX.md`, `config.yml`, `sources/`, `pages/`도 확인한다. 임베딩 모드이면 `wwiki serve --status`의 `running`도 확인한다.
4. 모두 정상이고 사용자가 업데이트나 설치 방식 변경을 요청하지 않았으면 **즉시 init을 종료한다.** 다시 클론·재설치하거나 설치 선택을 묻지 않는다. `wiki` 스킬에서 호출했으면 호출한 작업으로 돌아간다.
5. 미완료이면 필요한 단계만 이어간다. 설정만 유실됐으면 기존 도구의 설치 메타데이터와 vector 의존성을 확인해 복구한다. 선택을 확정할 수 없을 때만 사용자에게 묻는다. 데몬만 꺼졌다면 기존 vector 선택에 따라 다시 시작하고 검증한다.

빠른 종료에서는 원격 업데이트를 조회하지 않는다. 원격 업데이트 확인은 최초 설정·복구 과정 및 명시적인 업데이트 요청에서 수행한다(4절).

## 1. 디렉터리와 실행 도구 준비

`mkdir -p "$HOME/.fhdufhdu-wiki"`를 실행한다. `git`, `uv`를 확인하고, 부족한 도구는 현재 OS의 공식 설치 방식으로 준비한다. 현재 wwiki의 `pyproject.toml`에 있는 Python 요구 버전을 확인해 `uv`가 호환 인터프리터를 사용하도록 한다. 확인 당시 요구 버전은 Python 3.13 이상이다.

비공개 저장소 접근이 실패하면 `gh auth status`로 계정을 확인한다. 사용자가 사용할 계정을 지정했다면 해당 계정 인증을 명령 범위에만 적용할 수 있다. 토큰은 출력·파일 저장하지 않고 자식 프로세스의 환경에만 전달하며, 기존 Git credential helper 대신 `gh auth git-credential`을 해당 Git 명령에만 지정한다. 전역 Git 설정이나 다른 작업의 활성 계정을 바꾸지 않는다. `uv` 다운로드가 `UnknownIssuer`로 실패하면 OS 신뢰 저장소를 쓰는 `uv --system-certs ...`로 재시도한다.

기존 경로가 다른 저장소이거나 Git이 아닌 비어 있지 않은 경로면 덮어쓰지 않는다. 해당 경로와 문제를 알리고 사용자의 경로 정리 선택을 받는다. 실패한 클론도 무조건 삭제하지 말고 상태를 확인한다.

## 2. wwiki 클론과 설치 방식 선택

클론이 없을 때만 실행한다.

```bash
git clone https://github.com/fhdufhdu/wwiki.git "$HOME/.fhdufhdu-wiki/wwiki"
```

클론의 `README.md`, `pyproject.toml`, 필요하면 CLI 소스를 읽어 현재 설치·데몬 명령을 확인한다. 최초 설치에서는 사용자에게 **일반 설치(BM25 검색)**와 **임베딩 설치(하이브리드 검색, 모델 다운로드 및 백그라운드 메모리 사용)** 중 선택을 묻는다. 현재 vector 구성은 torch와 KURE 모델(약 2.2GB)을 사용하므로 이를 선택지에 설명한다. 이미 명시한 선택은 다시 묻지 않는다. 답이 오기 전 임의의 방식으로 설치하지 않는다.

일반 설치:

```bash
uv tool install --force --reinstall "$HOME/.fhdufhdu-wiki/wwiki"
```

임베딩 설치:

```bash
uv tool install --force --reinstall "$HOME/.fhdufhdu-wiki/wwiki[vector]"
wwiki serve --detach
wwiki serve --status
```

설치 후 도구 실행 파일이 PATH에 잡히는지 확인한다. 필요하면 `uv tool dir --bin`으로 실행 파일 위치를 찾아 절대 경로로 호출하고 PATH 설정 방법을 알린다.

`--detach`의 성공은 모델 준비 완료를 뜻하지 않는다. `--status`의 `running: true`가 될 때까지 짧은 간격으로 확인하고, 오래 걸리면 진행 상황과 `~/.cache/wwiki/serve.log`를 확인한다. 최초 다운로드 대기는 최대 10분으로 제한하고, 시간 초과나 오류면 미완료 상태와 재개 방법을 알린다. 이미 실행 중이면 중복 기동하지 않는다. 모델 로드나 다운로드가 실패했는데 기본 설치로 바꿔 완료 처리하지 않는다. 인증서 검증을 끄지 않는다.

## 3. 위키 저장소 클론과 준비

클론이 없을 때만 실행한다.

```bash
git clone https://github.com/fhdufhdu/wiki.git "$HOME/.fhdufhdu-wiki/wiki"
```

접근 권한·인증·네트워크 오류면 정확한 이유와 재개할 단계를 알린다. 다른 저장소를 만들거나 빈 위키로 대체하지 않는다. 이 저장소의 실제 구조와 `AGENTS.md`/`CLAUDE.md`, `SCHEMA.md`, `PROJECT.md`를 확인한다.

**클론한 저장소에 `wwiki new`를 실행하지 않는다.** 이 명령은 비어 있지 않은 디렉터리를 거부한다. 모든 CLI 작업은 `--wiki-root "$HOME/.fhdufhdu-wiki/wiki"`로 대상을 고정하므로 전역 위키 레지스트리 등록은 필요 없다.

관리 파일 상태를 `wwiki check`로 확인한다. 누락·구버전이면 `wwiki upgrade --dry-run`으로 변경할 파일을 확인한 후 기존 사용자 편집을 확인하고 필요한 승인을 받아 `wwiki upgrade`한다. upgrade는 `SCHEMA.md`, `CLAUDE.md`, `AGENTS.md`를 덮어쓴다. 위키가 아직 초기화되지 않았다면 설치된 wwiki 템플릿을 참조해 빠진 `PROJECT.md`, `INDEX.md`, `config.yml`, `sources/`, `pages/`만 준비한다. 기존 콘텐츠를 덮어쓰지 않는다. `PROJECT.md`의 사용자 규칙은 보존한다.

새로 클론한 위키는 `wwiki reindex --wiki-root "$HOME/.fhdufhdu-wiki/wiki"`로 기기별 인덱스를 재생성한다. 저장소에 추적된 SQLite 파일이 있어도 다른 기기에서 가져온 인덱스를 그대로 신뢰하지 않는다.

## 4. wwiki 업데이트 확인과 반영

최초 설정·복구 시, 또는 사용자가 업데이트를 요청하면 실행한다. 최초 설치 전에는 이 절의 원격 확인을 먼저 수행해 최신 소스를 설치하고, 이미 설치했다면 변경이 있을 때만 재설치한다.

1. wwiki 클론의 작업 트리·현재 브랜치·origin 기본 브랜치를 확인하고 `git fetch origin`으로 갱신 여부를 확인한다. 기본 브랜치를 `main`으로 단정하지 않는다.
2. 깨끗한 기본 브랜치이고 원격으로 fast-forward할 수 있을 때만 해당 원격 기본 브랜치로 `git merge --ff-only`한다. 로컬 수정·독자 커밋·분기·다른 브랜치가 있으면 보존하고 사유를 알린다. 자동 reset, stash, rebase는 하지 않는다.
3. HEAD가 `installed_commit`과 다르거나 설치 복구가 필요하면 선택한 `basic`/`vector` 방식을 유지해 2절 명령으로 재설치한다. 실행 중인 임베딩 데몬이 있으면 재설치 전 중지하고, 재설치 후 vector 모드에서는 재시작한다. 명시적으로 basic으로 바꾼 경우 기존 데몬을 중지한다.
4. CLI 소스 업데이트와 위키 관리 파일 업그레이드를 구분한다. 재설치 뒤 3절의 `wwiki check`와 필요 시 `upgrade --dry-run` 절차를 수행하고 `PROJECT.md`가 새 규칙과 맞는지 검토한다. `--all`로 다른 위키를 바꾸지 않는다.
5. 최종 CLI·관리 파일·선택 모드·데몬 상태를 확인한 뒤 성공한 커밋을 설정에 기록한다. 원격 조회 실패는 최신임을 의미하지 않는다. 기존 설치가 사용 가능하면 그 사실과 업데이트 미확인을 구분해 알린다.

위키 콘텐츠 저장소는 업데이트 대상 도구 저장소와 구분한다. init에서 위키의 로컬 변경을 강제로 동기화하거나 커밋·push하지 않는다.

## 완료

설치 방식, 두 클론 경로, wwiki 설치 커밋, 임베딩 데몬 상태(해당 시), 업데이트 확인 결과를 짧게 알린다. 미완료 항목이 있으면 환경 구성이 끝났다고 보고하지 않는다.
