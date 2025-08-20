#!/usr/bin/env nu

const config_path = path self ./init.lua

loop {
  let filepath = (xplr -C $config_path)
  if $filepath == "" {
    tmux kill-session
  }
  tmux send-keys -t 1 $"\u{1b}\u{1b}:o ($filepath)" C-m
  tmux select-pane -R
}
