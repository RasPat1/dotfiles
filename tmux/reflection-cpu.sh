#!/bin/sh
# CPU utilization as a % of total cores (macOS). Instant — no sampling delay.
ncpu=$(sysctl -n hw.ncpu)
ps -A -o %cpu | awk -v n="$ncpu" 'NR>1{s+=$1} END {if(n<1)n=1; v=s/n; if(v>100)v=100; printf "%d%%", v}'
