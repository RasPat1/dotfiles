#!/usr/bin/env bash
set -euo pipefail

src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$src_dir/config.toml"
dest="${CODEX_HOME:-$HOME/.codex}/config.toml"

mkdir -p "$(dirname "$dest")"

if [ ! -f "$dest" ]; then
  cp "$src" "$dest"
  exit 0
fi

ruby - "$src" "$dest" <<'RUBY'
src_path, dest_path = ARGV
src = File.read(src_path)
dest = File.read(dest_path)
tui = src[/^\[tui\]\n(?:.*\n)*?(?=^\[|\z)/, 0]
abort "missing [tui] block in #{src_path}" unless tui

if dest =~ /^\[tui\]\n(?:.*\n)*?(?=^\[|\z)/
  dest = dest.sub(/^\[tui\]\n(?:.*\n)*?(?=^\[|\z)/, tui.end_with?("\n") ? tui : "#{tui}\n")
else
  dest = dest.rstrip + "\n\n" + tui
end

File.write(dest_path, dest)
RUBY
