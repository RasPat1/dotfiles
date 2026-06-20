#!/bin/sh
# Free disk space on the volume holding $HOME (macOS). SI units (e.g. 750G).
df -H "$HOME" 2>/dev/null | awk 'NR==2 {print $4}'
