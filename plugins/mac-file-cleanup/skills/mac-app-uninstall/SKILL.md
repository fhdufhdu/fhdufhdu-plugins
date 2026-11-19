---
name: mac-app-uninstall
description: "macOS 앱을 관련 캐시·로그·LaunchAgent와 함께 제거한다. 앱 번들 ID로 연결되는 사용자 영역 파일만 찾아 미리보기를 만들고, 개인 데이터는 기본으로 남기며, 승인한 항목만 휴지통으로 보낸다. 'XX 앱 완전히 지워줘', '앱 삭제', '안 쓰는 앱 정리', 'Homebrew로 설치한 앱 제거'에 사용한다."
---

# Mac 앱 제거

로컬 macOS에서 실행한다. 관리자 권한(sudo)을 쓰지 않고, 휴지통을 비우지 않는다. 보호 규칙과 휴지통 이동은 같은 플러그인의 [mac-file-cleanup](../mac-file-cleanup/SKILL.md)과 [보호 목록](../mac-file-cleanup/references/protection.md)을 따른다. 앱 제거 규칙의 상세 근거는 [references/rules.md](references/rules.md)에 있다.

## 1. 앱 찾기

- 사용자가 앱 이름을 말하면 `/Applications`, `~/Applications`에서 `.app`을 찾는다. 여러 개가 맞으면(예: `Zed.app`, `Zed Nightly.app`) 목록을 보여 주고 고르게 한다. 이름이 비슷하다는 이유로 다른 앱을 고르지 않는다.
- "안 쓰는 앱 정리"처럼 대상을 정하지 않은 요청에는 두 폴더의 앱을 크기(`du -sk`)와 마지막 사용일(`mdls -raw -name kMDItemLastUsedDate`)로 정렬해 보여 주고, 사용자가 고르게 한다.
- `/System/Applications`의 Apple 앱과 Finder, Safari, Mail, 시스템 설정, App Store, 터미널은 제거 대상이 아니다.

## 2. 관련 파일 찾기

[find-app-files.sh](scripts/find-app-files.sh)를 실행한다. 읽기 전용이다.

```bash
scripts/find-app-files.sh "/Applications/Some App.app"
```

출력의 정보 줄(`#`)을 먼저 확인한다.

| 정보 | 처리 |
| --- | --- |
| `running yes` | 사용자에게 앱을 종료해 달라고 요청한다. 직접 `kill`하지 않는다. 종료 후 다시 실행해 확인한다. |
| `running unknown` | 실행 파일 이름이 Electron·node 같은 공유 런타임이라 판정할 수 없다. 사용자에게 앱이 꺼져 있는지 확인받는다. |
| `other_install yes` | 같은 번들 ID의 다른 설치본(베타·채널 빌드·업데이트 대기본)이 있다. 스크립트는 앱 번들만 출력한다. 잔여물·LaunchAgent는 다른 설치본이 쓰므로 건드리지 않는다. |
| `brew_cask <토큰>` | Homebrew로 설치한 앱이다. 4단계의 Homebrew 경로를 쓴다. |
| `mas yes` | App Store 앱이다. 휴지통으로 보내도 되지만 Launchpad에서 길게 눌러 삭제하는 방법도 안내한다. |
| `vendor_uninstaller yes` | 보안·VPN·관리 에이전트(백신, EDR, VPN, MDM 등)다. 휴지통으로 보내면 시스템 확장·데몬이 남는다. **직접 제거하지 않고** 제조사 제거 도구나 앱 안의 제거 메뉴를 안내한다. |

TSV 항목의 분류는 이렇다.

| 분류 | 의미 | 기본 선택 |
| --- | --- | --- |
| `APP` | 앱 번들 | 선택 |
| `DISPOSABLE` | 캐시·로그·HTTP 저장소·저장된 창 상태. 다시 만들어진다. | 선택 |
| `AGENT` | `~/Library/LaunchAgents`의 이 앱 소유 plist | 선택 |
| `PERSONAL` | 설정(`Preferences`), 앱 데이터(`Application Support`), 컨테이너 | **미선택**. 사용자가 "데이터까지 전부"라고 하거나 항목을 고를 때만 |
| `KEEP` | 그룹 컨테이너, 브라우저 프로필, VM·에뮬레이터 데이터 | **미선택**. "데이터까지 전부"여도 항목을 직접 지정할 때만 |

크기가 `?`인 항목은 Full Disk Access 권한 창을 피하려고 재지 않은 컨테이너다. 크기를 모른다고 표시한다.

## 3. 미리보기

앱 이름, 번들 ID, 실행 여부, 설치 방법(직접·Homebrew·App Store)을 먼저 적고, 항목을 "제거할 것"(APP, DISPOSABLE, AGENT)과 "남길 개인 데이터"(PERSONAL, KEEP)로 나눠 경로와 크기를 표로 보여 준다. 남길 데이터 중 지우고 싶은 것을 번호로 고를 수 있게 한다. 앱 번들의 상위 폴더에 쓰기 권한이 없으면(`[ -w "$(dirname "$app")" ]` 실패) 관리자 권한이 필요하다고 알리고 그 앱은 Finder에서 직접 지우도록 안내한다.

## 4. 제거

사용자가 승인한 항목만 처리한다. 실행 직전에 앱이 여전히 꺼져 있는지 다시 확인한다.

1. **LaunchAgent 내리기**: 승인된 `AGENT` plist마다 `launchctl bootout "gui/$(id -u)" "<plist 경로>"`를 실행한다(실패해도 계속하되 결과를 기록). 앱 안의 로그인 헬퍼(`<앱>/Contents/Library/LoginItems/*.app`)가 있으면 그 번들 ID로 `launchctl bootout "gui/$(id -u)/<헬퍼 ID>"`를 시도한다.
2. **Homebrew 앱**: 앱 번들은 `HOMEBREW_NO_AUTO_UPDATE=1 brew uninstall --cask <토큰>`으로 제거한다. `--zap`은 검토하지 않은 개인 데이터까지 지우므로 사용자가 따로 승인할 때만 붙이고, 먼저 `brew info --cask <토큰>`의 zap 대상 경로를 보여 준다. 실패하면 앱 번들을 휴지통으로 옮기지 말고 실패를 보고한다.
3. **그 밖의 항목**: [safe-trash.sh](../mac-file-cleanup/scripts/safe-trash.sh)로 휴지통에 보낸다. 라벨은 `-l "uninstall:<앱 이름>"`.

   ```bash
   ../mac-file-cleanup/scripts/safe-trash.sh -l "uninstall:Some App" "/Applications/Some App.app" "$HOME/Library/Caches/com.example.someapp"
   ```

4. **로그인 항목**: 시스템 설정 > 일반 > 로그인 항목에 남아 있을 수 있다. 백그라운드 항목(SMAppService)은 명령으로 지울 수 없으므로 사용자에게 확인하도록 안내한다.

## 5. 결과 보고

- 휴지통으로 보낸 것, 건너뛴 것(사유), 실패한 것, 남겨 둔 개인 데이터 경로를 나눠 보고한다. 실패가 있으면 "제거 완료"라고 말하지 않는다.
- 셸·에이전트 설정에 제거한 앱 경로가 남아 있는지 확인해 **파일과 줄 번호만** 알린다. 내용은 출력하지 않는다(자격 증명이 있을 수 있다). 대상: `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile`, `~/.profile`, `~/.config/fish/config.fish`, `~/.claude/settings.json`, `~/.claude.json`, `~/.codex/config.toml`, `~/.codex/hooks.json`, `~/.cursor/mcp.json`, `~/.gemini/settings.json`. 예: `grep -nF "/Applications/Some App.app" ~/.zshrc | cut -d: -f1`. 1MB가 넘거나 심볼릭 링크인 파일은 건너뛴다. 설정은 수정하지 않는다.
- 휴지통을 비워야 공간이 회수되며, 비우기 전에는 Finder에서 되돌릴 수 있다고 알린다.
