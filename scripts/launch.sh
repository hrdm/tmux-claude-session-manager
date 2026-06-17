#!/usr/bin/env bash
# Launch (or re-attach to) a Claude session for a directory, shown in a popup.
# Args: <dir> [origin-window-id]   (both expanded by run-shell in the binding)
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
. "$DIR/helpers.sh"

path="${1:-$PWD}"
window="${2:-}"

prefix="$(get_tmux_option @claude_session_prefix 'claude-')"
cmd="$(get_tmux_option @claude_command 'claude')"
w="$(get_tmux_option @claude_popup_width '90%')"
h="$(get_tmux_option @claude_popup_height '85%')"
title_bg="$(get_tmux_option @claude_popup_title_bg '#ff787d')"
title_fg="$(get_tmux_option @claude_popup_title_fg '#ffffff')"

# Toggle: if already inside any claude session, detach (closes the popup)
current="$(tmux display-message -p '#{session_name}')"
if [[ "$current" == "${prefix}"* ]]; then
  tmux detach-client
  exit 0
fi

session="${prefix}$(session_hash "$path")"

if ! tmux has-session -t "$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -c "$path" "$cmd"
  tmux set-option -t "$session" status off
fi

# Record which window launched it, so the picker can jump back here later.
[ -n "$window" ] && tmux set-option -t "$session" @claude_origin "$window"

tmux display-popup \
  -T "#[align=centre,bg=${title_bg},fg=${title_fg}] ✳ Claude Code " \
  -d "$path" \
  -w "$w" -h "$h" \
  -s 'bg=default' \
  -S "fg=${title_bg}" \
  -E "tmux attach-session -t $session"
