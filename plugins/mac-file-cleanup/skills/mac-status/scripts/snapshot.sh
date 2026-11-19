#!/bin/bash
# 읽기 전용: Mac 상태를 한 번 수집해 key<TAB>value 줄로 출력한다. 아무것도 바꾸지 않고 sudo를 쓰지 않는다.
# 각 항목은 실패해도 다른 항목에 영향을 주지 않는다(값이 비면 unavailable).
#
# 사용법: snapshot.sh
# 규칙 출처: Mole(https://github.com/tw93/Mole) cmd/status, lib/optimize/diagnostics.sh

set -u
export LC_ALL=C

kv() { printf '%s\t%s\n' "$1" "${2:-unavailable}"; }

# 시스템
kv model "$(sysctl -n hw.model 2>/dev/null)"
kv chip "$(sysctl -n machdep.cpu.brand_string 2>/dev/null)"
kv macos "$(sw_vers -productVersion 2>/dev/null) ($(sw_vers -buildVersion 2>/dev/null))"
boot=$(sysctl -n kern.boottime 2>/dev/null | sed -nE 's/^\{ sec = ([0-9]+),.*/\1/p')
[ -n "$boot" ] && kv uptime_days "$(( ($(date +%s) - boot) / 86400 ))"

# CPU: top 두 번째 샘플(1초 간격)의 사용률
cpu=$(top -l 2 -n 0 -s 1 2>/dev/null | grep 'CPU usage' | tail -1)
idle=$(printf '%s' "$cpu" | sed -nE 's/.* ([0-9.]+)% idle.*/\1/p')
[ -n "$idle" ] && kv cpu_used_pct "$(awk -v i="$idle" 'BEGIN{printf "%.1f", 100-i}')"
kv load_avg "$(sysctl -n vm.loadavg 2>/dev/null | tr -d '{}' | xargs)"
kv cpu_cores "$(sysctl -n hw.ncpu 2>/dev/null) (P $(sysctl -n hw.perflevel0.logicalcpu 2>/dev/null || echo ?), E $(sysctl -n hw.perflevel1.logicalcpu 2>/dev/null || echo ?))"

# 메모리: 압력 레벨(1 normal, 2 warn, 4 critical), 사용률은 vm_stat 기준(active+wired+compressed)
mem_total=$(sysctl -n hw.memsize 2>/dev/null)
lvl=$(sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null)
case "$lvl" in 1) kv memory_pressure normal ;; 2) kv memory_pressure warn ;; 4) kv memory_pressure critical ;; *) kv memory_pressure "" ;; esac
if [ -n "$mem_total" ]; then
  vm_stat 2>/dev/null | awk -v total="$mem_total" '
    /page size of/ { ps = $8 }
    /Pages active/ { a = $3 } /Pages wired down/ { w = $4 } /occupied by compressor/ { c = $5 }
    END { gsub(/\./,"",a); gsub(/\./,"",w); gsub(/\./,"",c); if (!ps) ps = 16384
          used = (a + w + c) * ps
          printf "memory_used_gb\t%.1f / %.1f\nmemory_used_pct\t%.1f\n", used/1073741824, total/1073741824, used*100/total }'
fi
kv swap "$(sysctl -n vm.swapusage 2>/dev/null)"

# 디스크: 데이터 볼륨 기준
df -k /System/Volumes/Data 2>/dev/null | awk 'NR==2 { printf "disk_used_pct\t%.1f\ndisk_free_gb\t%.1f\ndisk_total_gb\t%.1f\n", $3*100/($3+$4), $4/1048576, $2/1048576 }'
smart=$(diskutil info disk0 2>/dev/null | awk -F: '/SMART Status/ { gsub(/^ +/,"",$2); print $2 }')
kv disk_smart "$smart"
kv local_snapshots "$(tmutil listlocalsnapshots / 2>/dev/null | grep -c 'com.apple')"
kv trash_gb "$(/usr/bin/du -sk "$HOME/.Trash" 2>/dev/null | awk '{printf "%.1f", $1/1048576}')"

# 배터리
batt=$(pmset -g batt 2>/dev/null | sed -n 2p)
if printf '%s' "$batt" | grep -q '%'; then
  kv battery "$(printf '%s' "$batt" | sed -E 's/^.*\)[[:space:]]*//')"
  kv battery_cycles "$(ioreg -rn AppleSmartBattery 2>/dev/null | awk -F' = ' '/"CycleCount" =/ { print $2; exit }')"
  kv battery_health "$(system_profiler SPPowerDataType 2>/dev/null | awk -F': ' '/Maximum Capacity|Condition/ { printf "%s%s ", $1 ~ /Max/ ? "max " : "", $2 }' | sed -E 's/^ +//')"
  kv power_source "$(pmset -g batt 2>/dev/null | head -1 | sed -E "s/.*'(.*)'.*/\1/")"
else
  kv battery "none"
fi

# 프로세스 상위(CPU, 메모리)
ps -Aceo pid=,pcpu=,rss=,comm= -r 2>/dev/null | head -5 | awk '{ printf "top_cpu\t%s %s%% %.0fMB %s\n", $1, $2, $3/1024, substr($0, index($0,$4)) }'
ps -Aceo pid=,pcpu=,rss=,comm= -m 2>/dev/null | head -5 | awk '{ printf "top_mem\t%s %.0fMB %s%% %s\n", $1, $3/1024, $2, substr($0, index($0,$4)) }'

# 오래 돌며 CPU를 계속 쓰는 프로세스: 12시간 이상 실행, 누적 평균 CPU 25% 이상
ps -Ao pid=,time=,etime=,comm= 2>/dev/null | awk '
  function secs(t,   n, p, d, s) { d = 0; if (index(t, "-")) { split(t, p, "-"); d = p[1]; t = p[2] }
    n = split(t, p, ":"); s = 0; for (i = 1; i <= n; i++) s = s * 60 + p[i]; return d * 86400 + s }
  { cpu = secs($2); el = secs($3); name = $4
    if (name ~ /kernel_task|WindowServer|mds/) next
    if (el >= 43200 && cpu / el >= 0.25) printf "runaway\t%s %.0f%% avg %s\n", $1, cpu*100/el, name }'

# 유휴 VM: 가상화 프로세스가 2GB 이상인데 Docker 컨테이너가 0개
vm_rss=$(ps -Aceo rss=,comm= 2>/dev/null | awk '/Virtualization|com.apple.Virtualization|qemu/ { s += $1 } END { printf "%.1f", s/1048576 }')
kv vm_memory_gb "$vm_rss"
if command -v docker >/dev/null 2>&1 && pgrep -q com.docker.backend 2>/dev/null; then
  ctx=$(docker context show 2>/dev/null)
  kv docker_context "$ctx"
  kv docker_running_containers "$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')"
fi

# 사용자가 마운트한 디스크 이미지(시스템 관리 이미지 제외)
hdiutil info 2>/dev/null | awk '/^image-path/ { sub(/^image-path *: */, ""); img = $0 }
  /\/Volumes\// && img != "" && img !~ /CoreSimulator|Cryptex|cryptex|\/System\// { n = split($0, f, "\t"); printf "mounted_image\t%s -> %s\n", img, f[n]; img = "" }'

# 네트워크
kv default_interface "$(route -n get default 2>/dev/null | awk '/interface:/ { print $2 }')"
kv vpn_connected "$(scutil --nc list 2>/dev/null | grep -c Connected)"
