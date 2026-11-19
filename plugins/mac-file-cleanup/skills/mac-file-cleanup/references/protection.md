# 보호 목록과 판단 원칙

[Mole](https://github.com/tw93/Mole)의 보안 설계 문서(`docs/SECURITY_DESIGN.md`)와 사고 기록(`docs/incidents.md`)에서 가져온 규칙이다. 괄호 안의 `I-nn`은 Mole에서 실제로 데이터 손실이 났던 사고 번호다.

## 판단 원칙

- **모르면 남긴다.** 실행 여부, 열린 파일, 최근 활동, 설치 여부를 확인하는 검사가 실패하거나 시간 초과되면 그 항목은 "사용 중일 수 있음"으로 보고 후보에서 뺀다. 확인하지 못한 것을 "안전함"으로 해석하지 않는다.
- **실패는 그 항목만 건너뛴다.** 한 경로의 권한 오류나 시간 초과 때문에 전체 결과를 버리거나 다른 후보 판정을 바꾸지 않는다(I-72, I-80~82). 대신 미측정으로 기록한다.
- **중간에 끊긴 탐색 결과로 지우지 않는다.** `find`가 끝까지 완료된 목록만 후보로 쓴다.
- **폴더는 남기고 내용만 정리한다.** `~/Library/Caches`, `~/Library/Logs/DiagnosticReports`처럼 시스템이나 앱이 존재를 전제하는 폴더는 폴더 자체를 휴지통으로 보내지 않는다(I-03).
- **보고는 다시 잰 값으로 한다.** 처리 후 실제로 옮겨진 개수와 여유 공간을 다시 측정한다. 0건이거나 모두 실패했으면 "정리 완료"라고 말하지 않는다(I-53).

## 경로 위생

삭제나 이동 직전에 아래 중 하나라도 해당하면 거부한다.

- 절대 경로가 아니거나, 경로 구성요소로 `..`가 있거나, 제어 문자(개행 등)가 들어 있다.
- 변수가 비어 경로가 줄어든 결과로 보이는 경로: `/`, `/Users`, `/Users/<이름>`(홈 자체), `/Applications`, `~/Library`, `~/Library/<바로 아래 폴더>`.
- leaf뿐 아니라 **상위 경로 중 하나라도 심볼릭 링크**인 경우. `cd -P "$dir" && pwd -P`로 실제 경로를 구해 보호 목록과 다시 대조한다. 실제 경로는 거부 근거로만 쓰고 허용 근거로는 쓰지 않는다.
- APFS는 기본적으로 대소문자를 구분하지 않는다. `~/.Claude`와 `~/.claude`처럼 표기만 다른 경로가 같은 대상인지는 `[ "$a" -ef "$b" ]`로 비교한다.
- 셸 환경 변수로 받은 도구 경로(`CARGO_HOME`, `GRADLE_USER_HOME` 등)는 절대 경로이고 `..`나 개행이 없을 때만 따른다. 도구에게 캐시 경로를 묻는 명령(`uv cache dir`, `go env GOCACHE`, `npm config get cache`)이 실패하면 기본 경로로 추정하지 않고 건너뛴다.

## 캐시처럼 보이지만 지우면 안 되는 경로

이름이나 위치는 캐시지만 실제로는 설치물이나 사용자 데이터라 지우면 다시 설치하거나 복구할 수 없는 경로다. 후보로 올리지 않는다.

| 경로 | 이유 |
| --- | --- |
| `~/Library/Caches/ms-playwright*`, `~/Library/Caches/Cypress*`, `~/Library/Caches/camoufox`, `~/.cache/puppeteer` | 테스트용 브라우저 바이너리 설치본(I-42, I-45, I-48) |
| `~/.npm/_npx`, `~/.yarn/berry/cache`, `~/Library/Caches/pnpm/dlx` | 전역 실행 도구와 Yarn Berry 의존성 아카이브(I-11, I-22) |
| `~/Library/Caches/pypoetry/virtualenvs` | Poetry 프로젝트 가상환경 |
| `~/Library/Caches/llama.cpp`, Buzz 모델 폴더, `~/.ollama/models`, `~/.cache/huggingface` | 내려받은 AI 모델(I-63). 사용자가 직접 지정할 때만 검토 |
| `~/Library/Caches/kitty` | 터미널 설정·세션 상태(I-13) |
| `~/Library/Caches/com.apple.FontRegistry*`, `com.apple.Spotlight*`, `CloudKit*` | 시스템 구성요소 상태 |

## 항상 보호하는 사용자 데이터

- **AI 에이전트 상태**: `~/.claude`(특히 `projects`, `file-history`, `history.jsonl`), `~/.codex`(`sessions`, `auth.json`, `*.sqlite`), `~/Library/Application Support/{Claude,Codex,Cursor}`. 대화 기록과 인증 정보다(I-73).
- **iCloud 구조 폴더**: `~/Library/Mobile Documents`, 그 안의 각 앱 컨테이너, 각 컨테이너의 `Documents` 폴더 자체. 휴지통으로 보내면 같은 계정의 모든 기기에서 사라진다(I-27). 그 안의 개별 파일은 사용자가 지정하면 다룰 수 있다.
- **클라우드 동기화 폴더의 미다운로드 항목**: `~/Library/CloudStorage` 아래는 탐색하지 않는다. 사용자가 지정하면 `/usr/bin/find "$dir" -flags +dataless -prune -o ...`처럼 내려받지 않은 항목에는 들어가지 않는다(I-86). 열어 보기만 해도 다운로드가 시작될 수 있다.
- **SQLite 데이터베이스**: `*.db`, `*.sqlite`, `*.sqlite3`와 짝 파일 `-wal`, `-shm`, `-journal`은 한 묶음으로 다룬다. 짝 파일만 따로 지우지 않는다. `lsof`로 열려 있거나 확인할 수 없으면 제외한다.
- **보안 에이전트(EDR/MDM) 캐시**: `/var/folders` 안의 CrowdStrike, SentinelOne, Jamf, Microsoft Defender 등 경로. 지우면 변조 탐지가 걸릴 수 있다.
- **보호 앱 카테고리의 데이터**(캐시·로그 외 `Application Support`, `Containers`, `Group Containers`, `Preferences`): 비밀번호 관리자와 인증기(1Password, Bitwarden, KeePassXC, Authy, Yubico), 입력기, VPN·프록시(Clash, Surge, WARP, NetworkExtension 설정), IDE 설정(JetBrains, VS Code, Cursor, Sublime), DB 클라이언트, Postman, 노트 앱, 원격 접속, 브라우저 프로필, 클라우드 동기화 앱(Dropbox, OneDrive, Google Drive), 오디오 플러그인·라이선스(iLok, VST, `coreaudio`).
- **가상머신 디스크**: UTM, VirtualBuddy, Parallels, VMware, OrbStack, `Docker.raw`. 크기는 보여 주되 기본 선택하지 않는다(I-66).
- **공유 루트 폴더 자체**: `~/.cache`, `~/.config`, `~/.local/{bin,lib,share,state}`. 그 안의 개별 도구 폴더만 후보가 될 수 있다.

## 스냅샷과 백업

- 로컬 APFS 스냅샷과 Time Machine 스냅샷은 `tmutil listlocalsnapshots /`로 **개수와 이름만 보고**하고 삭제하지 않는다. 스냅샷이 지운 파일의 공간을 붙잡고 있어 여유 공간이 기대만큼 늘지 않을 수 있다고 설명한다. 네트워크 볼륨이 마운트되어 있으면 `tmutil`을 호출하지 않는다.
- 기기 백업(`~/Library/Application Support/MobileSync/Backup`)은 보호한다. 크기만 알리고, 정리는 Finder의 기기 관리 화면에서 하도록 안내한다.
