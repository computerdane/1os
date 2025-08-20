#!/usr/bin/env nu

loop {
  xplr | tmux send-keys -t 1 $"\u{1b}\u{1b}:o ($in)" C-m
  tmux select-pane -R
}
