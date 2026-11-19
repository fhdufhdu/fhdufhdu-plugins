#!/bin/bash
# 승인된 경로만 검증한 뒤 macOS 휴지통으로 보내고 처리 기록을 남긴다.
# 휴지통을 비우지 않고, 관리자 권한을 쓰지 않는다.
#
# 사용법: safe-trash.sh [-n] [-l 라벨] <경로>...
#   -n  검증만 하고 옮기지 않는다(dry-run). 기록에는 DRYRUN으로 남는다.
#   -l  기록에 함께 남길 작업 이름(예: clean, purge, installer, uninstall:<앱>)
#
# 표준 출력(TSV): 결과  KB  경로  사유
#   TRASHED  휴지통으로 이동함
#   DRYRUN   검증 통과(이동하지 않음)
#   SKIPPED  검증에서 거부함(사유 참고)
#   FAILED   이동을 시도했지만 실패함
# 종료 코드: 모두 성공 0, 하나라도 SKIPPED·FAILED면 1, 사용법 오류 2
#
# 기록: ~/Library/Logs/mac-file-cleanup/operations.tsv
#   시각(ISO8601)  실행ID  라벨  결과  KB  경로  사유
#
# 이 스크립트는 최소한의 안전장치다. 보호 목록 전체(references/protection.md)는
# 호출하기 전에 에이전트가 적용해야 한다.

set -u
export LC_ALL=C

DRY=0
LABEL=manual
while getopts "nl:" opt; do
  case "$opt" in
    n) DRY=1 ;;
    l) LABEL="$OPTARG" ;;
    *) echo "usage: $0 [-n] [-l label] <path>..." >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[ "$#" -ge 1 ] || { echo "usage: $0 [-n] [-l label] <path>..." >&2; exit 2; }

LOG_DIR="$HOME/Library/Logs/mac-file-cleanup"
LOG="$LOG_DIR/operations.tsv"
mkdir -p "$LOG_DIR" 2>/dev/null
RUN_ID="$(date +%Y%m%dT%H%M%S)-$$"
UID_NUM=$(id -u)
TRASH_BIN=/usr/bin/trash
[ -x "$TRASH_BIN" ] || TRASH_BIN=""

clean_field() { printf '%s' "$1" | tr '\t\n\r' '   '; }

log() { # result kb path reason
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$RUN_ID" \
    "$(clean_field "$LABEL")" "$1" "$2" "$(clean_field "$3")" "$(clean_field "$4")" >> "$LOG" 2>/dev/null
  printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$(clean_field "$3")" "$4"
}

# 경로 자체나 그 위로 올라가는 경로가 이 목록과 같으면 거부한다(빈 변수로 경로가 줄어든 경우 대비).
is_critical() {
  local p="$1"
  case "$p" in
    /|/System|/System/*|/usr|/usr/*|/bin|/bin/*|/sbin|/sbin/*|/private|/etc|/var|/Library|/Volumes|/Users|/Applications|/cores|/opt)
      case "$p" in /usr/local/*|/opt/homebrew/*) return 1 ;; esac
      return 0 ;;
    "$HOME"|"$HOME/Library"|"$HOME/Desktop"|"$HOME/Documents"|"$HOME/Downloads"|"$HOME/Movies"|"$HOME/Music"|"$HOME/Pictures"|"$HOME/.Trash"|"$HOME/.Trash/"*)
      return 0 ;;
  esac
  # ~/Library 바로 아래 폴더 자체(Caches, Logs, Containers ...)
  [ "$(dirname "$p")" = "$HOME/Library" ] && return 0
  return 1
}

# protection.md의 핵심 항목. 전체 목록은 에이전트가 미리 적용한다.
is_protected() {
  local p="$1" lc
  lc=$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')
  case "$lc" in
    "$(printf '%s' "$HOME" | tr '[:upper:]' '[:lower:]')"/.claude|*/.claude/projects*|*/.claude/file-history*|*/.claude/history.jsonl) return 0 ;;
    */.codex|*/.codex/sessions*|*/.codex/auth.json) return 0 ;;
    */library/mobile\ documents|*/library/mobile\ documents/*/documents|*/library/keychains*|*/library/accounts*) return 0 ;;
    */library/caches/ms-playwright*|*/library/caches/cypress*|*/library/caches/camoufox*|*/.cache/puppeteer*) return 0 ;;
    */.npm/_npx*|*/library/caches/pnpm/dlx*|*/.yarn/berry/cache*|*/.ssh|*/.ssh/*|*/.gnupg|*/.gnupg/*) return 0 ;;
    */library/application\ support/mobilesync/backup*) return 0 ;;
  esac
  # iCloud 앱 컨테이너 자체(~/Library/Mobile Documents/<컨테이너>)
  [ "$(dirname "$p")" = "$HOME/Library/Mobile Documents" ] && return 0
  return 1
}

rc=0
for p in "$@"; do
  reason=""
  if [ -z "$p" ]; then reason="빈 경로"
  elif [ "${p#/}" = "$p" ]; then reason="절대 경로 아님"
  elif printf '%s' "$p" | LC_ALL=C grep -q '[[:cntrl:]]'; then reason="제어 문자 포함"
  elif printf '%s' "$p" | grep -Eq '(^|/)\.\.?(/|$)'; then reason="경로에 . 또는 .. 구성요소"
  fi
  while [ "${#p}" -gt 1 ] && [ "${p%/}" != "$p" ]; do p="${p%/}"; done
  if [ -z "$reason" ]; then
    if [ ! -e "$p" ] && [ ! -L "$p" ]; then reason="존재하지 않음"
    elif [ -L "$p" ]; then reason="심볼릭 링크"
    elif is_critical "$p"; then reason="핵심 경로"
    elif is_protected "$p"; then reason="보호 경로"
    else
      parent=$(dirname "$p")
      real_parent=$(cd "$parent" 2>/dev/null && pwd -P) || real_parent=""
      if [ -z "$real_parent" ]; then reason="상위 경로 확인 실패"
      elif [ "$real_parent" != "$parent" ] && [ "$real_parent" != "/System/Volumes/Data$parent" ]; then
        reason="상위 경로에 심볼릭 링크($real_parent)"
      elif is_critical "$real_parent/$(basename "$p")" || is_protected "$real_parent/$(basename "$p")"; then
        reason="실제 경로가 보호 대상"
      elif [ "$(/usr/bin/stat -f '%u' "$p" 2>/dev/null)" != "$UID_NUM" ]; then
        reason="다른 사용자 소유"
      elif [ ! -w "$parent" ]; then
        reason="상위 폴더 쓰기 권한 없음(관리자 권한 필요)"
      elif [ -z "$TRASH_BIN" ] && ! command -v osascript >/dev/null; then
        reason="휴지통 도구 없음"
      fi
    fi
  fi

  kb=$(/usr/bin/du -k -x -s "$p" 2>/dev/null | cut -f1); kb=${kb:-0}
  if [ -n "$reason" ]; then
    log SKIPPED "$kb" "$p" "$reason"; rc=1; continue
  fi
  if [ "$DRY" = 1 ]; then
    log DRYRUN "$kb" "$p" "검증 통과"; continue
  fi

  if [ -n "$TRASH_BIN" ]; then
    out=$("$TRASH_BIN" "$p" 2>&1)
  else
    out=$(osascript - "$p" <<'OSA' 2>&1
on run argv
  tell application "Finder" to delete (POSIX file (item 1 of argv) as alias)
end run
OSA
)
  fi
  if [ -e "$p" ] || [ -L "$p" ]; then
    log FAILED "$kb" "$p" "${out:-원본이 남아 있음}"; rc=1
  else
    log TRASHED "$kb" "$p" "-"
  fi
done
exit "$rc"
