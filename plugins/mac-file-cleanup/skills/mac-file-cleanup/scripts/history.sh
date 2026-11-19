#!/bin/bash
# 읽기 전용: safe-trash.sh가 남긴 처리 기록을 요약한다.
#
# 사용법: history.sh [-n 실행개수] [-r 실행ID] [-a]
#   기본     최근 실행 10개를 실행별로 요약(라벨, 결과별 건수, 휴지통으로 보낸 용량)
#   -r ID    한 실행의 항목 전체
#   -a       기록 원본(TSV) 전체
#
# 기록 파일: ~/Library/Logs/mac-file-cleanup/operations.tsv
#   시각  실행ID  라벨  결과  KB  경로  사유

set -u
export LC_ALL=C
LOG="$HOME/Library/Logs/mac-file-cleanup/operations.tsv"
N=10
RUN=""
ALL=0
while getopts "n:r:a" opt; do
  case "$opt" in
    n) N="$OPTARG" ;;
    r) RUN="$OPTARG" ;;
    a) ALL=1 ;;
    *) echo "usage: $0 [-n runs] [-r run_id] [-a]" >&2; exit 2 ;;
  esac
done

[ -s "$LOG" ] || { echo "기록 없음: $LOG"; exit 0; }

if [ "$ALL" = 1 ]; then cat "$LOG"; exit 0; fi

if [ -n "$RUN" ]; then
  awk -F'\t' -v r="$RUN" '$2 == r { printf "%s\t%s\t%.1fMB\t%s\t%s\n", $4, $1, $5/1024, $6, $7 }' "$LOG"
  exit 0
fi

awk -F'\t' '
  !($2 in first) { first[$2] = $1; label[$2] = $3; order[++n] = $2 }
  { cnt[$2, $4]++; if ($4 == "TRASHED") kb[$2] += $5 }
  END {
    start = n - '"$N"' + 1; if (start < 1) start = 1
    printf "시작 시각\t실행ID\t라벨\t휴지통\t건너뜀\t실패\t미리보기\t휴지통 용량\n"
    for (i = n; i >= start; i--) {
      id = order[i]
      printf "%s\t%s\t%s\t%d\t%d\t%d\t%d\t%.2fGB\n", first[id], id, label[id],
        cnt[id, "TRASHED"], cnt[id, "SKIPPED"], cnt[id, "FAILED"], cnt[id, "DRYRUN"], kb[id] / 1048576
    }
  }' "$LOG"
