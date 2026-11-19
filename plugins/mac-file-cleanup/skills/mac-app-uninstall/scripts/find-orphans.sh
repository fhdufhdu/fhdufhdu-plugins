#!/bin/bash
# 읽기 전용: 이미 지운 앱이 남긴 사용자 영역 잔여물과, 사라진 실행 파일을 가리키는
# 백그라운드 항목(LaunchAgent·LaunchDaemon)을 찾는다. 아무것도 수정하지 않는다.
#
# 사용법: find-orphans.sh
#
# 출력: '#'로 시작하는 정보 줄 다음에 TSV(분류  KB  번들ID  경로)
#   분류
#     ORPHAN          설치된 앱·헬퍼·확장 어디에도 없는 번들 ID의 잔여물
#     REVIEW          설치된 앱과 같은 회사 제품이거나 보호 카테고리(비밀번호·VPN·동기화·IDE 등)
#                     라서 공용 데이터일 수 있음. 기본 미선택
#     AGENT_ORPHAN    ~/Library/LaunchAgents의 plist인데 실행 파일이 없음(사용자 권한으로 정리 가능)
#     SYSTEM_ORPHAN   /Library/LaunchAgents·LaunchDaemons의 plist인데 실행 파일이 없음(sudo 필요, 안내만)
#   KB가 '?'면 Full Disk Access 권한 창을 피하려고 재지 않은 컨테이너다.
#   AGENT_ORPHAN·SYSTEM_ORPHAN 줄에는 다섯째 열 'missing:<사라진 실행 파일 경로>'가 붙는다.
#
# 설치 판정: /Applications, ~/Applications, /Library/Application Support,
# /Library/PrivilegedHelperTools, /Library/SystemExtensions 아래 모든 번들(앱 안의 헬퍼·확장 포함),
# Spotlight가 아는 그 밖의 앱 번들(휴지통 제외), LaunchAgent·LaunchDaemon 이름을 모두 설치된 것으로 본다.
# 잔여물 번들 ID가 설치된 ID와 같거나, 한쪽이 다른 쪽의 접두사이거나, 앞 세 마디가 같으면 설치된 것으로 본다.

set -u
export LC_ALL=C
FIND=/usr/bin/find
L="$HOME/Library"
TMP=$(mktemp -d "${TMPDIR:-/tmp}/find-orphans.XXXXXX") || exit 1
trap 'rm -rf "$TMP"' EXIT

lower() { tr '[:upper:]' '[:lower:]'; }
prog_of() {
  /usr/libexec/PlistBuddy -c 'Print :Program' "$1" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c 'Print :ProgramArguments:0' "$1" 2>/dev/null
}

# 1. 설치된 번들 ID
{
  for d in /Applications "$HOME/Applications" "/Library/Application Support" /Library/PrivilegedHelperTools /Library/SystemExtensions; do
    [ -d "$d" ] || continue
    # 경로 조건 없이 모든 Info.plist를 본다. iPad 앱(Wrapper/*.app/Info.plist)과 프레임워크 안의 헬퍼도 잡기 위해서다.
    "$FIND" -P "$d" -name Info.plist -print0 2>/dev/null |
      while IFS= read -r -d '' f; do /usr/bin/plutil -extract CFBundleIdentifier raw "$f" 2>/dev/null; echo; done
  done
  mdfind 'kMDItemContentType == "com.apple.application-bundle"' 2>/dev/null |
    grep -v -e "^$HOME/.Trash/" -e '^/System/' |
    while IFS= read -r a; do /usr/bin/plutil -extract CFBundleIdentifier raw "$a/Contents/Info.plist" 2>/dev/null; echo; done
  # LaunchAgent·Daemon 이름은 실행 파일이 실제로 있을 때만 설치된 것으로 본다.
  # (실행 파일이 사라진 에이전트 이름까지 넣으면 그 앱의 잔여물이 설치된 것으로 오판된다.)
  for d in "$L/LaunchAgents" /Library/LaunchAgents /Library/LaunchDaemons; do
    for f in "$d"/*.plist; do
      [ -f "$f" ] || continue
      prog=$(prog_of "$f")
      case "$prog" in /*) [ -e "$prog" ] && basename "$f" .plist ;; esac
    done
  done
} | lower | grep -E '^[a-z0-9_-]+(\.[a-z0-9_-]+)+$' | sort -u > "$TMP/installed"

n_installed=$(wc -l < "$TMP/installed" | tr -d ' ')
if [ "$n_installed" -lt 20 ]; then
  echo "error: 설치된 앱을 거의 찾지 못했습니다($n_installed개). Spotlight·권한 문제일 수 있어 판정하지 않습니다." >&2
  exit 1
fi
echo "# installed_ids	$n_installed"

# 2. 잔여물 후보: 번들 ID 모양의 이름만
C_DIR="$(getconf DARWIN_USER_CACHE_DIR 2>/dev/null)"; C_DIR="${C_DIR%/}"
{
  for d in "$L/Application Support" "$L/Containers" "$L/Group Containers" "$L/Preferences" "$L/Preferences/ByHost" \
           "$L/Caches" "$L/HTTPStorages" "$L/WebKit" "$L/Saved Application State" "$L/Logs" "$L/Application Scripts" \
           "$L/Cookies" "$L/Application Support/CrashReporter" \
           "$L/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments" \
           ${C_DIR:+"$C_DIR"}; do
    [ -d "$d" ] || continue
    for p in "$d"/*; do
      [ -e "$p" ] || continue
      [ -L "$p" ] && continue
      printf '%s\n' "$p"
    done
  done
} > "$TMP/paths"

# 이름 → 번들 ID 정규화와 설치 대조는 awk 한 번으로 처리한다(bash 3.2 호환).
awk -v installed="$TMP/installed" '
function vendor(id,   n, c) {
  n = split(id, c, ".")
  if (c[1] ~ /^(com|org|net|io|dev|app|co|me|sh|ai|us|de|fr|jp|kr|ch|at|dk|pro|llc|edu|uk|cn|tv|so|is|gg|xyz)$/) return c[2]
  return c[1]
}
BEGIN {
  while ((getline id < installed) > 0) {
    inst[id] = 1
    n = split(id, c, ".")
    pre = c[1]
    for (i = 2; i <= n; i++) { pre = pre "." c[i]; if (i >= 3) ipre[pre] = 1 }
    v = vendor(id); if (length(v) >= 2) ivend[v] = 1
  }
  protect = "password|1password|bitwarden|keepass|authy|yubico|safe-in-cloud|vpn|tunnel|proxy|wireguard|onedrive|dropbox|drivefs|googledrive|icloud|jetbrains|postman|keychain|ssh|gpg"
}
{
  path = $0
  n = split(path, seg, "/"); name = seg[n]
  b = tolower(name)
  sub(/\.(plist|savedstate|binarycookies|sfl[0-9]?)$/, "", b)
  sub(/\.shipit.*$/, "", b)
  sub(/[._][0-9a-f]+-[0-9a-f]+-[0-9a-f]+-[0-9a-f]+-[0-9a-f]+$/, "", b)   # ByHost·CrashReporter UUID
  if (b ~ /^[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]\./) b = substr(b, 12)  # 팀 ID 접두사(WQL32M5H24.)
  sub(/^group\./, "", b)
  if (b !~ /^[a-z0-9_-]+\.[a-z0-9_-]+\.[a-z0-9_.-]+$/ || b ~ /\.\.|\.$/) next   # 번들 ID 모양(마디 3개 이상)만
  if (b ~ /\.(log|txt|tmp|gz|lock|sock|db|json|xml|zip)$/) next
  # Apple(단축어의 옛 ID is.workflow 포함)·보안 에이전트·도구 캐시 이름은 제외
  if (b ~ /^(com\.apple\.|apple\.|systemgroup\.|groups\.com\.apple|is\.workflow\.|com\.microsoft\.wdav|com\.crowdstrike|com\.sentinelone|com\.jamf|main\.kts\.)/) next
  if (b in inst || b in ipre) next
  m = split(b, c, "."); pre = c[1]; hit = 0
  for (i = 2; i <= m; i++) { pre = pre "." c[i]; if (i >= 3 && (pre in inst)) { hit = 1; break } }
  if (hit) next
  if (m >= 3 && ((c[1] "." c[2] "." c[3]) in ipre)) next
  cat = "ORPHAN"
  if ((vendor(b) in ivend) || b ~ protect) cat = "REVIEW"
  printf "%s\t%s\t%s\n", cat, b, path
}' "$TMP/paths" | sort -t "$(printf '\t')" -k1,1 -k2,2 > "$TMP/found"

while IFS="$(printf '\t')" read -r cat bid p; do
  case "$p" in
    "$L/Containers/"*|"$L/Group Containers/"*) kb="?" ;;
    *) kb=$(/usr/bin/du -k -x -s "$p" 2>/dev/null | cut -f1); kb=${kb:-?} ;;
  esac
  printf '%s\t%s\t%s\t%s\n' "$cat" "$kb" "$bid" "$p"
done < "$TMP/found"

# 3. 실행 파일이 사라진 백그라운드 항목
for d in "$L/LaunchAgents" /Library/LaunchAgents /Library/LaunchDaemons; do
  for f in "$d"/*.plist; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in com.apple.*) continue ;; esac
    prog=$(prog_of "$f")
    # Program이 없는 빈 plist(<dict/>)는 자동 업데이트를 막으려고 일부러 둔 것일 수 있어 건너뛴다.
    [ -n "$prog" ] || continue
    case "$prog" in /*) ;; *) continue ;; esac   # 상대 경로·명령 이름은 판정하지 않는다
    [ -e "$prog" ] && continue
    if [ "$d" = "$L/LaunchAgents" ]; then cat=AGENT_ORPHAN; else cat=SYSTEM_ORPHAN; fi
    printf '%s\t-\t%s\t%s\tmissing:%s\n' "$cat" "$(basename "$f" .plist)" "$f" "$prog"
  done
done
