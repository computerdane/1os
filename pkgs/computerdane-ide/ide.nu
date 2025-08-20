#!/usr/bin/env nu

const loop_xplr_path = path self ./loop-xplr.nu

(tmux new-session $loop_xplr_path ";"
  split-window -h ";"
  resize-pane -t 0 -x 35 ";"
  send-keys -t 1 "hx; tmux kill-session" C-m ";"
  select-pane -L ";"
  set-option -g escape-time 5 ";"
  set-option -g default-terminal 'xterm-256color' ";"
  bind h select-pane -L ";"
  bind l select-pane -R
)
