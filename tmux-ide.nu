#!/usr/bin/env nu

(tmux new-session ./loop-xplr.nu ";"
  split-window -h -p 75 ";"
  send-keys -t 1 "hx; tmux kill-session" C-m ";"
  select-pane -L ";"
  set-option -g escape-time 5 ";"
  set-option -g default-terminal 'xterm-256color' ";"
  bind h select-pane -L ";"
  bind l select-pane -R
)
