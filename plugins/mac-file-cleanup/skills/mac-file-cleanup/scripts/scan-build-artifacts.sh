#!/bin/bash
# 읽기 전용: 프로젝트 루트 아래의 빌드 산출물 후보를 찾아 재생성 가능성을 판정한다.
# 아무 파일도 수정·삭제하지 않는다.
#
# 사용법: scan-build-artifacts.sh [-d 최근일수] [-m 최소KB] <프로젝트루트>...
# 출력(TSV, 크기 내림차순): 판정  KB  경로  매니페스트
#   OK            매니페스트가 있고, Git 추적 파일·중첩 저장소·최근 수정이 없음
#   RECENT        최근 N일 안에 하위 항목이 수정됨 (또는 활동 검사 실패)
#   NO_MANIFEST   부모 폴더에 매니페스트가 없어 재생성 방법을 확인할 수 없음
#   NESTED_GIT    산출물 안에 .git이 있음
#   TRACKED       Git이 추적하는 파일이 들어 있음
#   SYMLINK       심볼릭 링크
#
# 셸의 find·du가 bfs·dust 같은 대체 도구로 alias되어 있을 수 있으므로
# 반드시 /usr/bin 절대 경로를 사용한다.

set -u
export LC_ALL=C

FIND=/usr/bin/find
DU=/usr/bin/du
DAYS=7
MIN_KB=10240

while getopts "d:m:" opt; do
  case "$opt" in
    d) DAYS="$OPTARG" ;;
    m) MIN_KB="$OPTARG" ;;
    *) echo "usage: $0 [-d days] [-m min_kb] <root>..." >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[ "$#" -ge 1 ] || { echo "usage: $0 [-d days] [-m min_kb] <root>..." >&2; exit 2; }

MANIFEST_RE='^(Cargo\.toml|package\.json|build\.gradle(\.kts)?|settings\.gradle(\.kts)?|pom\.xml|Package\.swift|pyproject\.toml|requirements\.txt|uv\.lock|go\.mod|Gemfile|composer\.json|pubspec\.yaml|CMakeLists\.txt|Makefile)$'

tmp=$(mktemp -t scan-build-artifacts) || exit 1
trap 'rm -f "$tmp"' EXIT

for root in "$@"; do
  [ -d "$root" ] || { echo "skip: not a directory: $root" >&2; continue; }
  # 산출물 폴더를 찾으면 그 안으로는 내려가지 않는다(-prune). 앱 번들·.git도 가지치기한다.
  "$FIND" -P "$root" -xdev \
    \( -name .git -o -name '*.app' -o -name '*.photoslibrary' \) -prune -o \
    -type d \( -name node_modules -o -name target -o -name .build -o -name build \
      -o -name dist -o -name .next -o -name .nuxt -o -name .output -o -name .turbo \
      -o -name .parcel-cache -o -name .gradle -o -name .venv -o -name venv \
      -o -name __pycache__ -o -name DerivedData -o -name .dart_tool -o -name Pods \) \
    -prune -print0 2>/dev/null
done | while IFS= read -r -d '' p; do
  kb=$("$DU" -k -x -s "$p" 2>/dev/null | cut -f1)
  [ -n "$kb" ] && [ "$kb" -ge "$MIN_KB" ] || continue

  parent=$(dirname "$p")
  name=$(basename "$p")
  manifest=$(ls -1 "$parent" 2>/dev/null | grep -E "$MANIFEST_RE" | head -1)

  if [ -L "$p" ]; then
    verdict=SYMLINK
  elif [ -z "$manifest" ]; then
    verdict=NO_MANIFEST
  else
    # 오류가 나면 출력이 생기므로 RECENT로 취급한다(활동을 검사할 수 없으면 건너뛴다).
    recent=$("$FIND" -P "$p" -xdev -newermt "$DAYS days ago" -print -quit 2>&1)
    nested=$("$FIND" -P "$p" -xdev -maxdepth 4 -name .git -print -quit 2>/dev/null)
    tracked=""
    if top=$(git -C "$parent" rev-parse --show-toplevel 2>/dev/null); then
      real_parent=$(cd "$parent" && pwd -P)
      rel="${real_parent#"$top"}"; rel="${rel#/}"
      rel="${rel:+$rel/}$name"
      tracked=$(git --literal-pathspecs -C "$top" ls-files --cached -- "$rel" 2>/dev/null | head -1)
    fi
    if [ -n "$recent" ]; then verdict=RECENT
    elif [ -n "$nested" ]; then verdict=NESTED_GIT
    elif [ -n "$tracked" ]; then verdict=TRACKED
    else verdict=OK
    fi
  fi
  printf '%s\t%s\t%s\t%s\n' "$verdict" "$kb" "$p" "${manifest:--}"
done > "$tmp"

sort -t "$(printf '\t')" -k2,2nr "$tmp"
