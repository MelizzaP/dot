# Surface terminal failures through the tmux notification system used by
# Claude Code hooks (~/.dot/bin/tmux-claude-alert). When a command exits
# non-zero, stamp the window with the orange 󱍋 indicator the status format
# (tmux.conf:82) already understands — unless the command's non-zero exit
# is part of its normal contract (grep no-match, fzf cancel, etc.).

# Benign non-zero exits — don't alert on these.
set -g __tmux_alert_ignore \
    grep rg ag ack \
    diff cmp \
    fzf \
    test : '[' '[[' \
    man less more \
    jq

function __tmux_alert_on_failure --on-event fish_postexec
    # Capture status FIRST — every subsequent command resets it.
    set -l code $status
    set -l cmd $argv[1]

    set -q TMUX; or return
    test $code -eq 0; and return
    test $code -eq 130; and return  # SIGINT (Ctrl-C) — user-initiated
    test -z "$cmd"; and return

    # First "real" token, skipping leading VAR=value env assignments.
    set -l first
    for tok in (string split -n ' ' -- $cmd)
        string match -qr '^[A-Za-z_][A-Za-z0-9_]*=' -- $tok; and continue
        set first (path basename -- $tok)
        break
    end
    test -z "$first"; and return

    contains -- $first $__tmux_alert_ignore; and return

    ~/.dot/bin/tmux-claude-alert 󱍋 '#e69875' >/dev/null 2>&1
end
