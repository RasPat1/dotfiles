#!/bin/sh
# Battery percentage (macOS); falls back to "AC" on desktops / when no % is reported.
b=$(pmset -g batt 2>/dev/null | grep -Eo '[0-9]+%' | head -1)
[ -n "$b" ] && printf '%s' "$b" || printf 'AC'
