---
name: mac-status
description: "Mac 상태(CPU, 메모리 압력, 스왑, 디스크, 배터리, 오래 도는 프로세스, 유휴 VM)를 읽기 전용으로 진단해 건강 점수와 함께 요약하고, 관리자 권한 없이 할 수 있는 가벼운 유지보수(QuickLook 캐시 새로고침, 오래된 창 상태 정리, 손상된 설정 파일 점검 등)를 승인받아 실행한다. 'Mac이 느려', '상태 확인', '최적화해줘', '메모리 부족', '배터리 상태'에 사용한다."
---

# Mac 상태와 최적화

로컬 macOS에서 실행한다. 진단은 읽기 전용이다. 유지보수 작업은 항목별로 미리보기를 보여 주고 승인받은 것만 실행한다. 관리자 권한(sudo)을 쓰지 않고, 프로세스를 직접 종료하지 않는다. 디스크 정리는 [mac-file-cleanup](../mac-file-cleanup/SKILL.md), 앱 제거는 [mac-app-uninstall](../mac-app-uninstall/SKILL.md)로 넘긴다.

규칙 출처는 [Mole](https://github.com/tw93/Mole)의 `mo status`(`cmd/status`)와 `mo optimize`(`lib/optimize`)다.

## 1. 진단

[snapshot.sh](scripts/snapshot.sh)를 실행한다. 4초쯤 걸린다. 값이 `unavailable`인 항목은 측정하지 못한 것이다. 0이나 정상으로 해석하지 않는다.

```bash
scripts/snapshot.sh
```

### 건강 점수

100점에서 아래만큼 뺀다. 결과는 0~100으로 자르고, 85 이상 좋음, 65 이상 보통, 45 이상 주의, 그 아래는 나쁨이다.

| 항목 | 감점 |
| --- | --- |
| CPU 사용률(`cpu_used_pct`) | 50% 초과분에 비례해 최대 30점. 85% 초과면 가파르게 |
| 메모리 사용률(`memory_used_pct`) | 70% 초과분에 비례해 최대 25점. 압력 `warn` -5, `critical` -15 추가 |
| 디스크 사용률(`disk_used_pct`) | 80% 초과분에 비례해 최대 20점. `disk_smart`가 `Failing`이면 점수 상한 44 |
| 배터리 | 상태(`battery_health`)가 `Service Recommended` 등 경고면 -5 |
| 가동 시간(`uptime_days`) | 7일 초과 -1, 14일 초과 -3 |

점수는 참고용이다. 아래 진단 결과를 함께 보여 준다.

### 진단 기준

- **메모리 부족**: 압력이 `warn`·`critical`이거나 스왑 사용이 전체의 50% 이상이면 경고하고 `top_mem` 상위 프로세스를 보여 준다. `memory_pressure` 명령의 출력은 레벨 이름을 주지 않으므로 `kern.memorystatus_vm_pressure_level`만 쓴다.
- **디스크 거의 가득 참**: 사용률 90% 이상이면서 여유 30GB 미만이면 mac-file-cleanup을 권한다. 로컬 스냅샷이 있으면 지운 파일 공간을 붙잡고 있을 수 있다고 알린다(삭제는 하지 않는다). 휴지통 크기도 함께 알린다.
- **오래 도는 프로세스**(`runaway`): 12시간 넘게 실행되며 평균 CPU 25% 이상. 종료는 사용자가 판단하도록 PID와 이름만 알린다. `kernel_task`, `WindowServer`, `mds`는 제외한다.
- **유휴 VM**: 가상화 프로세스 메모리(`vm_memory_gb`)가 2GB 이상인데 로컬 Docker 컨텍스트에서 실행 중인 컨테이너가 0개면 Docker Desktop을 종료하라고 권한다.
- **시스템 서비스 과부하**: `top_cpu`에 Spotlight(`mds`, `mdworker`), `syspolicyd`, `WindowServer`가 계속 높게 나오면 원인 후보로 알린다. `syspolicyd`가 높고 사용자가 마운트한 이미지(`mounted_image`)가 있으면 꺼내기를 제안한다.
- **배터리**: 사이클 수와 최대 용량(`max 87%` 등), 상태를 그대로 전달한다.

## 2. 유지보수(최적화)

진단 결과와 관계없이 사용자가 "최적화해줘"라고 하면 아래 표에서 **필요한 것만** 골라 미리보기로 보여 준다. 필요 없는 작업은 "건너뜀(이유)"로 적는다. 승인한 항목만 실행하고 결과를 항목별로 보고한다.

### 사용자 권한으로 하는 작업

| 작업 | 필요 조건 | 실행 |
| --- | --- | --- |
| QuickLook 썸네일 새로고침 | 미리보기 아이콘이 깨지거나 오래됨 | `qlmanage -r cache` 후 `qlmanage -r`. 자동 재생성되며 위험이 낮다. |
| 오래된 창 상태 정리 | `~/Library/Saved Application State`에서 30일 넘게 바뀌지 않은 `*.savedState` | 실행 중인 앱의 것은 제외하고 [safe-trash.sh](../mac-file-cleanup/scripts/safe-trash.sh) `-l optimize`로 휴지통에 보낸다. |
| 손상된 설정 파일 점검 | `~/Library/Preferences`(깊이 1)와 `ByHost`의 `.plist` 중 `plutil -lint`가 실패하는 파일 | `com.apple.*`, `.GlobalPreferences*`, `loginwindow.plist`, 읽을 수 없는 파일은 제외한다. 목록을 보여 주고, 승인하면 해당 앱을 종료한 상태에서 휴지통으로 보낸다(앱이 기본 설정으로 다시 만든다). |
| 깨진 LaunchAgent 보고 | `~/Library/LaunchAgents/*.plist`의 `Program`(또는 `ProgramArguments` 첫 값)이 절대 경로인데 파일이 없음 | 보고만 한다. 마운트되지 않은 `/Volumes` 경로는 깨진 것으로 보지 않는다. 지우려면 mac-app-uninstall의 LaunchAgent 절차를 따른다. |
| 로그인 항목 점검 | 시스템 설정의 로그인 항목 중 앱이 없는 것 | `osascript -e 'tell application "System Events" to get the path of every login item'`으로 목록을 얻어 없는 경로를 보고한다. 삭제는 시스템 설정에서 하도록 안내한다. |
| 사용자 디스크 이미지 꺼내기 | `mounted_image`에 사용자가 마운트한 dmg·iso가 있음 | 승인한 이미지만 `diskutil eject <장치>`. CoreSimulator·cryptex 같은 시스템 이미지는 제외한다. |
| 네트워크·USB의 .DS_Store 생성 끄기 | 사용자가 원할 때만(설정 변경) | `defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true`(USB는 `DSDontWriteUSBStores`). 되돌리기 명령(`defaults delete ...`)을 함께 알린다. |

### 하지 않는 작업

아래는 관리자 권한이 필요하거나 시스템 데이터를 직접 고쳐 위험하다. 필요해 보이면 이유와 명령을 알려 주고 사용자가 직접 실행하게 한다.

- DNS 캐시 비우기(`sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`). VPN이 연결되어 있으면 권하지 않는다.
- Spotlight 재색인(`sudo mdutil -E /`). 검색이 3초 넘게 걸리는 등 실제 문제가 있을 때만, 전원 연결 상태에서.
- 사용자 권한 복구(`diskutil resetUserPermissions / $(id -u)`), `periodic` 유지보수, `diskutil verifyVolume /`(시스템이 멈출 수 있다).
- 알림 DB·knowledgeC DB 행 삭제, Mail·Safari·Messages DB `VACUUM`(시스템 DB 직접 수정, Full Disk Access 필요).
- 프로세스 강제 종료, 앱 실행 파일에서 Intel 코드 제거(코드 서명이 깨진다).
