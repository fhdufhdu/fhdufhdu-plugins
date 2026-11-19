#!/bin/bash
# 읽기 전용: 프로젝트 루트 아래의 빌드 산출물 후보를 찾아 재생성 가능성을 판정한다.
# 아무 파일도 수정·삭제하지 않는다.
#
# 사용법: scan-build-artifacts.sh [-d 최근일수] [-m 최소KB] <프로젝트루트>...
# 출력(TSV, 크기 내림차순): 판정  KB  경로  근거
#   OK            이름에 맞는 증거가 있고, 아래 제외 조건에 하나도 걸리지 않음
#   RECENT        최근 N일 안에 하위 항목이 수정됨 (또는 활동 검사 실패)
#   IN_USE        현재 사용자 프로세스가 안쪽 파일을 열었거나 작업 디렉터리로 사용 중
#   NO_EVIDENCE   이름에 맞는 증거(매니페스트·pyvenv.cfg 등)가 없어 재생성 방법을 확인할 수 없음
#   LOCAL_EDIT    node_modules에 설치 기록보다 새로 바뀐 파일이 있음(직접 수정 가능성)
#   NESTED_GIT    산출물 안에 .git이 있음
#   SECRET        산출물 안에 *-keypair.json 같은 키 파일이 있음
#   TRACKED       Git이 추적하는 파일이 들어 있음
#   SYMLINK       심볼릭 링크
#
# 셸의 find·du가 bfs·dust 같은 대체 도구로 alias되어 있을 수 있으므로
# 반드시 /usr/bin 절대 경로를 사용한다. 검사가 실패하면 보존 쪽으로 판정한다.
# 규칙 출처: Mole(https://github.com/tw93/Mole) lib/clean/project.sh, purge_shared.sh

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

tmp=$(mktemp -t scan-build-artifacts) || exit 1
openf=$(mktemp -t scan-build-artifacts-lsof) || exit 1
trap 'rm -f "$tmp" "$openf"' EXIT

# 현재 사용자의 열린 파일·작업 디렉터리 목록을 한 번만 받는다. 실패하면 모두 IN_USE로 본다.
LSOF_OK=1
if ! /usr/sbin/lsof -nP -a -u "$(id -u)" -Fn 2>/dev/null | sed -n 's/^n//p' | sort -u > "$openf"; then
  LSOF_OK=0
fi
[ -s "$openf" ] || LSOF_OK=0

# 이름별 증거. 성공하면 근거 문자열을 출력하고 0을 반환한다.
evidence() {
  local p="$1" parent name f lock rec
  parent=$(dirname "$p"); name=$(basename "$p")
  case "$name" in
    target)
      for f in Cargo.toml pom.xml; do [ -f "$parent/$f" ] && { echo "$f"; return 0; }; done
      [ -f "$p/.rustc_info.json" ] && { echo ".rustc_info.json"; return 0; } ;;
    .build)
      [ -f "$parent/Package.swift" ] && { echo "Package.swift"; return 0; }
      for f in workspace-state.json build.db; do [ -f "$p/$f" ] && { echo "$f"; return 0; }; done ;;
    venv|.venv)
      [ -f "$p/pyvenv.cfg" ] && { echo "pyvenv.cfg"; return 0; } ;;
    node_modules)
      [ -f "$parent/package.json" ] || return 1
      for pair in package-lock.json:.package-lock.json npm-shrinkwrap.json:.package-lock.json \
                  pnpm-lock.yaml:.modules.yaml yarn.lock:.yarn-integrity yarn.lock:.yarn-state.yml; do
        lock="${pair%%:*}"; rec="${pair#*:}"
        if [ -f "$parent/$lock" ] && [ -f "$p/$rec" ] && [ ! -L "$p/$rec" ]; then
          echo "$lock+$rec"; return 0
        fi
      done ;;
    DerivedData)
      { [ -f "$p/info.plist" ] || [ -d "$p/Build" ]; } && { echo "info.plist|Build"; return 0; } ;;
    *)
      for f in Cargo.toml package.json build.gradle build.gradle.kts settings.gradle settings.gradle.kts \
               pom.xml Package.swift pyproject.toml requirements.txt setup.py uv.lock go.mod Gemfile \
               pubspec.yaml CMakeLists.txt Makefile angular.json svelte.config.js svelte.config.ts \
               astro.config.mjs astro.config.ts build.zig; do
        [ -f "$parent/$f" ] && { echo "$f"; return 0; }
      done ;;
  esac
  return 1
}

in_use() {
  [ "$LSOF_OK" = 1 ] || return 0
  local real
  real=$(cd "$1" 2>/dev/null && pwd -P) || return 0
  awk -v p="$real" 'index($0, p "/") == 1 || $0 == p { found=1; exit } END { exit !found }' "$openf"
}

for root in "$@"; do
  [ -d "$root" ] || { echo "skip: not a directory: $root" >&2; continue; }
  # 산출물 폴더를 찾으면 그 안으로는 내려가지 않는다(-prune). 앱 번들·.git·클라우드 폴더도 가지치기한다.
  "$FIND" -P "$root" -xdev \
    \( -name .git -o -name '*.app' -o -name '*.photoslibrary' -o -name CloudStorage -o -name 'Mobile Documents' \) -prune -o \
    -type d \( -name node_modules -o -name target -o -name .build -o -name build \
      -o -name dist -o -name .next -o -name .nuxt -o -name .output -o -name .turbo \
      -o -name .parcel-cache -o -name .gradle -o -name .venv -o -name venv \
      -o -name __pycache__ -o -name .pytest_cache -o -name .mypy_cache -o -name .ruff_cache \
      -o -name .tox -o -name .nox -o -name DerivedData -o -name .dart_tool -o -name Pods \
      -o -name .angular -o -name .svelte-kit -o -name .astro -o -name .zig-cache -o -name zig-out \
      -o -name .cxx -o -name .terragrunt-cache \) \
    -prune -print0 2>/dev/null
done | while IFS= read -r -d '' p; do
  kb=$("$DU" -k -x -s "$p" 2>/dev/null | cut -f1)
  [ -n "$kb" ] && [ "$kb" -ge "$MIN_KB" ] || continue

  parent=$(dirname "$p")
  name=$(basename "$p")
  why=$(evidence "$p") || why=""

  if [ -L "$p" ]; then
    verdict=SYMLINK
  elif [ -z "$why" ]; then
    verdict=NO_EVIDENCE; why="-"
  else
    # 오류가 나면 출력이 생기므로 RECENT로 취급한다(활동을 검사할 수 없으면 건너뛴다).
    recent=$("$FIND" -P "$p" -xdev -newermt "$DAYS days ago" -print -quit 2>&1)
    nested=$("$FIND" -P "$p" -xdev -maxdepth 4 -name .git -print -quit 2>/dev/null)
    secret=$("$FIND" -P "$p" -xdev -maxdepth 4 -name '*-keypair.json' -print -quit 2>/dev/null)
    local_edit=""
    if [ "$name" = node_modules ]; then
      rec="$p/${why#*+}"
      local_edit=$("$FIND" -P "$p" -xdev -type d -path "$p/.cache" -prune -o -type f -newer "$rec" -print -quit 2>&1)
    fi
    tracked=""
    if top=$(git -C "$parent" rev-parse --show-toplevel 2>/dev/null); then
      real_parent=$(cd "$parent" && pwd -P)
      rel="${real_parent#"$top"}"; rel="${rel#/}"
      rel="${rel:+$rel/}$name"
      tracked=$(git --literal-pathspecs -C "$top" ls-files --cached -- "$rel" 2>/dev/null | head -1)
    fi
    if [ -n "$recent" ]; then verdict=RECENT
    elif in_use "$p"; then verdict=IN_USE
    elif [ -n "$nested" ]; then verdict=NESTED_GIT
    elif [ -n "$secret" ]; then verdict=SECRET
    elif [ -n "$local_edit" ]; then verdict=LOCAL_EDIT
    elif [ -n "$tracked" ]; then verdict=TRACKED
    else verdict=OK
    fi
  fi
  printf '%s\t%s\t%s\t%s\n' "$verdict" "$kb" "$p" "$why"
done > "$tmp"

sort -t "$(printf '\t')" -k2,2nr "$tmp"
