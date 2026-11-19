#!/bin/bash
# 읽기 전용: 앱 번들 하나에 딸린 사용자 영역 파일을 찾아 분류한다. 아무것도 수정하지 않는다.
#
# 사용법: find-app-files.sh </Applications/Some.app>
#
# 출력: '#'로 시작하는 정보 줄 다음에 TSV(분류  KB  경로)
#   정보 줄: bundle_id, name, executable, running, other_install, brew_cask, mas, vendor_uninstaller
#   분류
#     APP         앱 번들 자체
#     DISPOSABLE  다시 만들어지는 캐시·로그(기본 선택)
#     PERSONAL    설정·앱 데이터·컨테이너(기본 미선택, 사용자가 고를 때만)
#     KEEP        그룹 컨테이너·브라우저 프로필·VM 데이터 등(--with-data여도 미선택)
#     AGENT       ~/Library/LaunchAgents의 이 앱 소유 plist(기본 선택, 제거 전 unload 필요)
#
# 규칙 출처: Mole(https://github.com/tw93/Mole) lib/core/app_protection.sh find_app_files,
# lib/uninstall/review.sh, lib/uninstall/batch.sh

set -u
export LC_ALL=C
FIND=/usr/bin/find
DU=/usr/bin/du
L="$HOME/Library"

app="${1:-}"
[ -n "$app" ] || { echo "usage: $0 <path/to/App.app>" >&2; exit 2; }
app="${app%/}"
case "$app" in /*.app) ;; *) echo "error: .app 절대 경로가 필요합니다: $app" >&2; exit 2 ;; esac
[ -d "$app" ] && [ ! -L "$app" ] || { echo "error: 앱 번들이 없거나 심볼릭 링크입니다: $app" >&2; exit 2; }
case "$app" in /System/*) echo "error: 시스템 앱은 제거하지 않습니다" >&2; exit 2 ;; esac

plist="$app/Contents/Info.plist"
read_key() { /usr/bin/plutil -extract "$1" raw "$plist" 2>/dev/null; }
bid=$(read_key CFBundleIdentifier)
bname=$(read_key CFBundleName)
exe=$(read_key CFBundleExecutable)
name=$(basename "$app" .app)

# reverse-DNS 형식이 아니면 번들 ID로 경로를 만들지 않는다.
if ! printf '%s' "$bid" | grep -Eq '^[A-Za-z0-9-]+(\.[A-Za-z0-9_-]+)+$'; then
  echo "# bundle_id	(없음 또는 형식 오류: ${bid:-?}) — 번들 ID 기반 탐색 생략"
  bid=""
fi

# Apple 시스템 앱은 거부
case "$bid" in
  com.apple.finder|com.apple.Safari|com.apple.mail|com.apple.systempreferences|com.apple.Settings|com.apple.AppStore|com.apple.Terminal|com.apple.ActivityMonitor)
    echo "error: 시스템 핵심 앱($bid)은 제거하지 않습니다" >&2; exit 2 ;;
esac

running=no
if [ -n "$exe" ] && pgrep -xq "$exe" 2>/dev/null; then running=yes; fi
case "$exe" in Electron|node|java|python|python3) [ "$running" = yes ] && running="unknown(공유 런타임 이름)";; esac

# 같은 번들 ID의 다른 설치본(채널 빌드, 다른 위치)이 있으면 잔여물은 건드리지 않는다.
other=no
if [ -n "$bid" ]; then
  others=$(mdfind "kMDItemCFBundleIdentifier == '$bid'" 2>/dev/null | grep -v -F -x "$app" | grep '\.app$' | grep -v "^$app/" | head -3)
  [ -n "$others" ] && other="yes: $(printf '%s' "$others" | tr '\n' ';')"
fi

cask=""
if command -v brew >/dev/null 2>&1; then
  for d in /opt/homebrew/Caskroom /usr/local/Caskroom; do
    [ -d "$d" ] || continue
    cask=$(grep -rlsF --include='*.rb' "\"$name.app\"" "$d"/*/.metadata 2>/dev/null | head -1 | sed -E "s#^$d/([^/]+)/.*#\1#")
    [ -n "$cask" ] && break
  done
fi

mas=no; [ -d "$app/Contents/_MASReceipt" ] && mas=yes

vendor=no
case "$(printf '%s %s' "$name" "$bid" | tr '[:upper:]' '[:lower:]')" in
  *eset*|*jamf*|*crowdstrike*|*falcon*|*sentinel*|*globalprotect*|*paloalto*|*cisco*|*anyconnect*|*teamviewer*|*"adobe genuine"*|*avast*|*avg*|*malwarebytes*|*bitdefender*|*kaspersky*|*norton*|*sophos*|*"creative cloud"*|*alyac*|*"f5 vpn"*|*"f5 endpoint"*|*com.f5.*)
    vendor=yes ;;
esac

printf '# bundle_id\t%s\n# name\t%s\n# bundle_name\t%s\n# executable\t%s\n# running\t%s\n# other_install\t%s\n# brew_cask\t%s\n# mas\t%s\n# vendor_uninstaller\t%s\n' \
  "${bid:--}" "$name" "${bname:--}" "${exe:--}" "$running" "$other" "${cask:--}" "$mas" "$vendor"

emit() { # category path
  local c="$1" p="$2" kb
  [ -e "$p" ] || return 0
  # VM·에뮬레이터·브라우저 프로필 데이터는 개인 데이터 중에서도 기본 미선택(KEEP)
  if [ "$c" = PERSONAL ]; then
    case "$p" in
      *com.utmapp.UTM*|*VirtualBuddy*|*com.parallels*|*com.vmware*|*Whisky*|*CrossOver*|*OpenEmu*|*Dolphin*|*minecraft*|\
      */Google/Chrome*|*/BraveSoftware*|*/Microsoft\ Edge*|*/Firefox*|*/Arc/User\ Data*|*company.thebrowser.Browser*) c=KEEP ;;
    esac
  fi
  [ -L "$p" ] && return 0
  case "$p" in "$L"|"$L/Caches"|"$L/Logs"|"$L/Application Support"|"$L/Preferences"|"$L/Containers"|"$L/Group Containers"|"$HOME/.config"|"$HOME/.cache"|"$HOME/.local/share") return 0 ;; esac
  # Containers 안쪽은 Full Disk Access 권한 창을 띄울 수 있어 크기를 재지 않는다.
  case "$p" in "$L/Containers/"*|"$L/Group Containers/"*) kb="?" ;; *) kb=$("$DU" -k -x -s "$p" 2>/dev/null | cut -f1); kb=${kb:-?} ;; esac
  printf '%s\t%s\t%s\n' "$c" "$kb" "$p"
}

classify_cache() { # path → DISPOSABLE 또는 데이터가 사는 캐시면 PERSONAL
  case "$1" in
    "$L/Caches/com.spotify.client"*|"$L/Caches/com.raycast.macos"*|"$L/Caches/MullvadBrowser"*|"$L/Caches/Buzz"*) echo PERSONAL ;;
    *) echo DISPOSABLE ;;
  esac
}

{
  emit APP "$app"

  # 다른 설치본이 있으면 앱 번들만 다룬다.
  case "$other" in yes*) exit 0 ;; esac

  if [ -n "$bid" ]; then
    for p in "$L/Caches/$bid" "$L/Caches/$bid.ShipIt" "$L/Logs/$bid"; do emit "$(classify_cache "$p")" "$p"; done
    for p in "$L/HTTPStorages/$bid" "$L/HTTPStorages/$bid.binarycookies" "$L/WebKit/$bid" \
             "$L/Saved Application State/$bid.savedState"; do emit DISPOSABLE "$p"; done
    for p in "$L/Application Support/$bid" "$L/Preferences/$bid.plist" "$L/Containers/$bid" \
             "$L/Application Scripts/$bid" "$L/Cookies/$bid.binarycookies" "$L/Autosave Information/$bid"; do emit PERSONAL "$p"; done
    "$FIND" -P "$L/Preferences/ByHost" -maxdepth 1 -name "$bid.*.plist" -print0 2>/dev/null |
      while IFS= read -r -d '' p; do emit PERSONAL "$p"; done
    # 그룹 컨테이너는 이름이 <id>, <id>.*, *.<id>일 때만
    "$FIND" -P "$L/Group Containers" -mindepth 1 -maxdepth 1 \( -name "$bid" -o -name "$bid.*" -o -name "*.$bid" \) -print0 2>/dev/null |
      while IFS= read -r -d '' p; do emit KEEP "$p"; done
    # LaunchAgents: 파일명이 <id>.plist 이거나 Program이 이 앱 안을 가리킬 때만
    for p in "$L/LaunchAgents/"*.plist; do
      [ -f "$p" ] || continue
      case "$(basename "$p")" in com.apple.*) continue ;; esac
      prog=$(/usr/libexec/PlistBuddy -c 'Print :Program' "$p" 2>/dev/null || /usr/libexec/PlistBuddy -c 'Print :ProgramArguments:0' "$p" 2>/dev/null)
      if [ "$(basename "$p")" = "$bid.plist" ] || case "$prog" in "$app/"*) true ;; *) false ;; esac; then
        emit AGENT "$p"
      fi
    done
  fi

  # 이름 기반: 3자 이상이고 번들 파일명 그대로일 때만(표시 이름·유사 이름 금지)
  if [ "${#name}" -ge 3 ]; then
    for p in "$L/Caches/$name" "$L/Logs/$name"; do emit "$(classify_cache "$p")" "$p"; done
    emit PERSONAL "$L/Application Support/$name"
    emit PERSONAL "$L/Saved Application State/$name.savedState"
    for p in "$HOME/.config/$name" "$HOME/.local/share/$name"; do emit PERSONAL "$p"; done
    emit DISPOSABLE "$HOME/.cache/$name"
  fi
} | awk -F'\t' '!seen[$3]++'
