#!/bin/bash
# Health-check for the pass-cli SSH agent daemon.
# ssh-add -l on the agent socket is the real liveness test:
# the systemd unit is oneshot, so it reports "active" even after
# the daemon process has crashed.
export SSH_AUTH_SOCK=/home/equilone/.ssh/proton-pass-agent.sock
if ssh-add -l >/dev/null 2>&1; then
    exit 0  # agent alive and serving keys
fi
# Distinguish "daemon dead" (connection refused) from "daemon alive
# but Pass locked" (agent answers, just no keys) — only restart on dead.
if ! ssh-add -l 2>&1 | grep -qi 'connection refused\|no such file\|connect failed'; then
    exit 0  # socket answered; keys likely locked, don't restart
fi
systemctl --user restart pass-ssh-agent.service
sleep 5
export SSH_AUTH_SOCK=/home/equilone/.ssh/proton-pass-agent.sock
ssh-add -l >/dev/null 2>&1
