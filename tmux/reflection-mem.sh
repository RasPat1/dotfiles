#!/bin/sh
# Used RAM in GB (macOS): active + wired + compressed pages, via vm_stat.
psize=$(sysctl -n hw.pagesize)
vm_stat | awk -v p="$psize" '
  /Pages active/                 {gsub(/\./,"",$3); a=$3}
  /Pages wired down/             {gsub(/\./,"",$4); w=$4}
  /Pages occupied by compressor/ {gsub(/\./,"",$5); c=$5}
  END {printf "%.1fG", (a+w+c)*p/1073741824}'
