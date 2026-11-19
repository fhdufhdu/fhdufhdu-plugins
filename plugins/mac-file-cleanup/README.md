# Mac 파일 정리

macOS 기본 도구로 디스크를 분석·정리하고, 앱을 제거하고, 시스템 상태를 진단하는 Codex·Claude Code 플러그인입니다. 모든 정리는 미리보기 후 승인한 항목만 휴지통으로 보냅니다.

## 설치

[저장소 README](../../README.md)에 따라 `fhdufhdu` 마켓플레이스를 등록한 뒤 설치합니다.

**Codex CLI**

```bash
codex plugin add mac-file-cleanup@fhdufhdu
```

**Claude Code 세션**

```text
/plugin install mac-file-cleanup@fhdufhdu
```

## 스킬

| 스킬 | 하는 일 | Mole 대응 |
| --- | --- | --- |
| `mac-file-cleanup` | 디스크 사용량 분석, 캐시·로그·설치 파일·빌드 산출물·개발 도구 데이터 정리, 지난 정리 기록 조회 | `clean`, `analyze`, `purge`, `installer`, `history` |
| `mac-app-uninstall` | 앱과 번들 ID로 연결된 캐시·로그·LaunchAgent 제거(개인 데이터는 기본 보존), 이미 지운 앱의 잔여물과 실행 파일이 사라진 백그라운드 항목 찾기 | `uninstall` |
| `mac-status` | CPU·메모리 압력·디스크·배터리 진단과 건강 점수, 관리자 권한 없는 유지보수 | `status`, `optimize`(사용자 권한 작업만) |

Mole의 `slim`(앱에서 Intel 코드 제거)과 관리자 권한이 필요한 `optimize` 작업(DNS 캐시 비우기, Spotlight 재색인 등)은 포함하지 않습니다. 코드 서명이 깨지거나 sudo가 필요하기 때문입니다.

## 사용

Codex에서는 스킬 선택기에서 스킬을 고르고, Claude Code에서는 `/mac-file-cleanup:<스킬 이름> <요청>`으로 입력합니다. 자연어로 요청해도 맞는 스킬이 선택됩니다.

- `용량이 부족해 정리 좀 하자`: 데이터 볼륨 여유 공간부터 확인하고, 라이브러리·다운로드·개발 도구 캐시를 크기순으로 조사합니다.
- `다운로드 폴더의 설치 파일 정리해줘`: dmg·pkg·iso·설치용 zip을 찾습니다(마운트 중인 이미지 제외).
- `~/project 아래 빌드 산출물 정리해줘`: `node_modules`, `target`, `build`, `.venv` 등을 이름별 증거·Git 추적·최근 수정·열린 파일 기준으로 판정합니다.
- `지난번에 뭐 지웠어?`: 처리 기록을 실행별로 요약합니다.
- `Postman 완전히 지워줘`: 앱과 캐시·로그를 지우고 설정·데이터는 남깁니다.
- `삭제한 앱이 남긴 흔적 찾아줘`: 설치된 앱과 대조해 남은 설정·컨테이너·캐시와, 실행 파일이 사라진 LaunchAgent·LaunchDaemon을 찾습니다. 시스템 영역은 직접 실행할 sudo 명령만 안내합니다.
- `Mac이 느려`, `최적화해줘`: 상태를 진단하고 필요한 유지보수만 제안합니다.

스크립트는 직접 실행할 수도 있습니다. 모두 플러그인 폴더 기준 경로입니다.

```bash
skills/mac-file-cleanup/scripts/scan-build-artifacts.sh ~/project   # 빌드 산출물 판정(읽기 전용)
skills/mac-file-cleanup/scripts/safe-trash.sh -n <경로>...           # 휴지통 이동 전 검증만
skills/mac-file-cleanup/scripts/history.sh                          # 처리 기록 요약
skills/mac-app-uninstall/scripts/find-app-files.sh /Applications/Some.app
skills/mac-app-uninstall/scripts/find-orphans.sh                  # 이미 지운 앱의 흔적(읽기 전용)
skills/mac-status/scripts/snapshot.sh                               # 상태 수집(읽기 전용)
```

## 정리 방식

- 후보는 **바로 정리 가능 / 사용자 판단 필요 / 건너뜀** 세 묶음으로 보여 주고, 고른 번호만 처리합니다.
- 확인할 수 없는 항목(실행 여부, 열린 파일, 최근 활동을 판정하지 못한 것)은 남깁니다.
- 파일과 폴더는 검증 후 휴지통으로 옮기고 `~/Library/Logs/mac-file-cleanup/operations.tsv`에 기록합니다. 휴지통은 비우지 않으므로, 실제 공간을 확보하려면 Finder에서 직접 비워야 합니다.
- Docker 정리나 `cargo clean`처럼 도구 명령으로 정리하는 항목은 즉시 삭제되며, 따로 승인을 받은 뒤에만 실행합니다.
- 관리자 권한(sudo)을 쓰지 않습니다.

보호 목록, 후보 선별, 미리보기 후 승인 방식은 [Mole](https://github.com/tw93/Mole)의 보안 설계와 사고 기록을 참고했습니다.
