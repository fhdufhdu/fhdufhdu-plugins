# 앱 제거 규칙의 근거

[Mole](https://github.com/tw93/Mole)의 `mo uninstall`(`lib/uninstall/*.sh`, `lib/core/app_protection.sh`)에서 가져온 규칙과 사고 기록(`docs/incidents.md`)이다.

## 관련 파일을 찾는 방법

- **번들 ID가 기준이다.** `plutil -extract CFBundleIdentifier raw <앱>/Contents/Info.plist`로 읽고, reverse-DNS 형식(`com.example.app`)일 때만 경로를 만든다. 형식이 이상하면 번들 ID 기반 탐색을 하지 않는다.
- **이름은 번들 파일명 그대로만 쓴다.** 표시 이름이나 비슷한 이름으로 넓혀 찾지 않는다. "Alfred 4"처럼 숫자가 붙은 이름은 `CFBundleName`이 숫자를 뗀 이름과 같을 때만 축약한다(I-78).
- **채널 빌드를 조심한다.** `Zed Nightly`를 지울 때 `Zed`의 데이터 폴더를 제안하면 안 된다. 같은 번들 ID 또는 기본 이름의 다른 설치본이 있으면 잔여물은 건드리지 않고 앱 번들만 다룬다(I-24).
- **그룹 컨테이너·컨테이너는 이름이 정확히 맞을 때만**: `<id>`, `<id>.*`, `*.<id>`. UUID 이름의 컨테이너는 안의 `.com.apple.containermanagerd.metadata.plist`의 `MCMMetadataIdentifier`가 번들 ID와 같을 때만 이 앱 것으로 본다.
- **LaunchAgent 소유 판정**: 파일명이 `<id>.plist`이거나, plist의 `Program`·`ProgramArguments`의 첫 값이 이 앱 번들 안을 가리킬 때만. `com.apple.*`은 제외.
- **공유 루트와 다른 도구의 데이터는 제외**: `~/.cache`, `~/.config`, `~/.local/share` 루트 자체, `~/Library/Unity`, `Application Support/Epic`. Claude 데스크톱 앱을 지울 때 `~/.claude`(Claude Code CLI 데이터)를 함께 지우면 안 된다(Mole #993).

## 기본 선택

- 기본으로 지우는 것은 `~/Library/Caches/*`, `~/Library/Logs/*`, HTTP 저장소, 저장된 창 상태, 이 앱 소유 LaunchAgent뿐이다.
- 단, 캐시 폴더에 실제 데이터를 두는 앱은 개인 데이터로 본다: Spotify(오프라인 음악), Raycast(클립보드 이미지), Mullvad Browser(프로필), Buzz(모델·플러그인)(I-65).
- 설정·앱 데이터·컨테이너는 개인 데이터라 기본으로 남긴다. "데이터까지 전부 지워줘"여도 그룹 컨테이너, 브라우저 프로필, VM·에뮬레이터 데이터는 항목을 직접 지정할 때만 지운다(I-66).
- 다른 앱의 컨테이너 크기는 재지 않는다. Full Disk Access가 없으면 macOS 권한 창이 뜬다(I-54).

## 제거 방식

- 실행 중인 앱은 사용자에게 종료를 요청한다. Mole은 `osascript -e 'tell application id "<id>" to quit'` 후 SIGTERM·SIGKILL을 보내지만, 에이전트는 저장되지 않은 작업을 날릴 수 있어 직접 종료하지 않는다.
- Homebrew cask는 `brew uninstall --cask`로 지운다. Mole은 기본으로 `--zap`을 붙이지만, 이 스킬은 개인 데이터를 기본으로 남기는 원칙이라 `--zap`을 따로 승인받는다. 같은 번들 ID를 공유하는 다른 cask(예: iterm2와 iterm2-beta)가 있으면 `--zap`은 쓰지 않는다.
- 보안·VPN·관리 에이전트(ESET, Jamf, CrowdStrike, SentinelOne, GlobalProtect, Cisco, TeamViewer, Avast, Malwarebytes, Bitdefender, Kaspersky, Norton, Sophos, 알약, F5 등)는 제조사 제거 도구로 안내한다. 휴지통으로 보내면 시스템 확장과 데몬이 남는다.
- 시스템 영역(`/Library/LaunchDaemons`, `/Library/Application Support`, `/Library/Extensions`, `/Library/Receipts`)의 잔여물은 관리자 권한이 필요하므로 다루지 않는다. 남아 있으면 경로만 알린다.
- 실패를 성공으로 보고하지 않는다(I-25).

## 제거 후

- 셸·에이전트 설정 파일에 제거한 앱 경로가 남았는지 **파일과 줄 번호만** 알린다. 내용은 출력하지 않고 수정하지 않는다.
- 이미 앱이 지워진 뒤 남은 잔여물은 mac-file-cleanup의 "제거한 앱의 잔여 파일" 규칙으로 찾는다.
