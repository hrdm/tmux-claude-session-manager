#!/usr/bin/env bash
# Open the session picker in a popup.
# Arg: <client-name> of the triggering client (expanded by run-shell), stashed
# so the picker can move that client to the chosen session's origin window.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
. "$DIR/helpers.sh"

tmux set-option -g @claude_parent "${1:-}"
tmux set-option -gu @claude_pending_popup 2>/dev/null

title_bg="$(get_tmux_option @claude_popup_title_bg '#ff787d')"
title_fg="$(get_tmux_option @claude_popup_title_fg '#ffffff')"
w="$(get_tmux_option @claude_popup_width '90%')"
h="$(get_tmux_option @claude_popup_height '90%')"
tmux display-popup \
  -T "#[align=centre,bg=${title_bg},fg=${title_fg}] ✳ Claude Session Manager " \
  -w "$w" -h "$h" \
  -s 'bg=default' \
  -S "fg=${title_bg}" \
  -E "$DIR/picker.sh"

# picker.sh sets @claude_pending_popup when a session is selected.
# Open it here in a styled popup, matching the launch.sh appearance.
target="$(get_tmux_option @claude_pending_popup '')"
tmux set-option -gu @claude_pending_popup 2>/dev/null
[ -z "$target" ] && exit 0

title_bg="$(get_tmux_option @claude_popup_title_bg '#ff787d')"
title_fg="$(get_tmux_option @claude_popup_title_fg '#ffffff')"
pw="$(get_tmux_option @claude_popup_width '90%')"
ph="$(get_tmux_option @claude_popup_height '85%')"
tmux display-popup \
  -T "#[align=centre,bg=${title_bg},fg=${title_fg}] ✳ Claude Code " \
  -w "$pw" -h "$ph" \
  -s 'bg=default' \
  -S "fg=${title_bg}" \
  -E "tmux attach-session -t $target"
