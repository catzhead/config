#!/usr/bin/env bash
# SwiftBar plugin: the Fleet dashboard's headline numbers in the Mac menu
# bar. Polls Prometheus on levitate-sim (company tailnet) every minute —
# the "1m" in the filename is the refresh interval. Shows a dash when the
# Mac is not on the company tailnet. Managed by
# the chezmoi dotfiles (catzhead/config); `chezmoi update` installs it on every Mac.
#
# <swiftbar.title>Fleet</swiftbar.title>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>
# <swiftbar.environment>[]</swiftbar.environment>

PROM="http://100.116.37.48:18009"
GRAFANA="http://100.116.37.48:18010/d/fleet"
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

q() { curl -s --max-time 4 -G "$PROM/api/v1/query" --data-urlencode "query=$1" 2>/dev/null \
      | jq -r '.data.result[] | "\(.metric.host) \(.value[1])"' 2>/dev/null; }

short() { case "$1" in levitate-sim) echo sim ;; levitate-dev-01) echo dev ;; levitate-ci-01) echo ci ;; *) echo "${1%%.*}" ;; esac; }
color() { local v=${1%.*}; if [ "$v" -ge 90 ]; then echo red; elif [ "$v" -ge 70 ]; then echo orange; else echo green; fi; }
pct() { printf '%.0f' "$1"; }

cpu="$(q '100 * (1 - avg by (host) (rate(node_cpu_seconds_total{mode="idle"}[2m])))')"
if [ -z "$cpu" ]; then
  echo "fleet –"
  echo "---"
  echo "Prometheus unreachable | color=gray"
  echo "Is the Mac on the company tailnet? | color=gray"
  echo "Retry | refresh=true"
  exit 0
fi
mem="$(q '100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)')"
disk="$(q '100 * (1 - node_filesystem_avail_bytes{mountpoint="/",fstype!="rootfs"} / node_filesystem_size_bytes{mountpoint="/",fstype!="rootfs"})')"
load="$(q 'node_load1 / on (host) count by (host) (node_cpu_seconds_total{mode="idle"})')"
up="$(q 'up{job="node"}')"

# Menu bar line: one entry per host, worst colour wins.
title=""; worst=green
while read -r host v; do
  [ -n "$host" ] || continue
  u="$(echo "$up" | awk -v h="$host" '$1==h{print $2}')"
  if [ "${u:-0}" != "1" ]; then title+="$(short "$host") down  "; worst=red; continue; fi
  c="$(color "$v")"; [ "$c" = red ] && worst=red; [ "$c" = orange ] && [ "$worst" != red ] && worst=orange
  title+="$(short "$host") $(pct "$v")%  "
done <<< "$cpu"
echo "⬢ ${title% } | color=$worst font=Menlo size=12"
echo "---"
echo "Fleet — CPU · mem · disk · load/core | size=11 color=gray"
while read -r host v; do
  [ -n "$host" ] || continue
  m="$(echo "$mem"  | awk -v h="$host" '$1==h{print $2}')"
  d="$(echo "$disk" | awk -v h="$host" '$1==h{print $2}')"
  l="$(echo "$load" | awk -v h="$host" '$1==h{print $2}')"
  u="$(echo "$up"   | awk -v h="$host" '$1==h{print $2}')"
  if [ "${u:-0}" != "1" ]; then echo "$host  DOWN | color=red font=Menlo"; continue; fi
  printf '%-16s cpu %3s%%  mem %3s%%  disk %3s%%  load %.2f | font=Menlo color=%s\n' \
    "$host" "$(pct "$v")" "$(pct "${m:-0}")" "$(pct "${d:-0}")" "${l:-0}" "$(color "$v")"
done <<< "$cpu"
echo "---"
echo "Open Fleet dashboard | href=$GRAFANA"
echo "Refresh | refresh=true"
