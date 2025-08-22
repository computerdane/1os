#!/usr/bin/env nu

def main [filepath: string] {
  let panes = (tmux list-panes | lines | length)
  if $panes < 2 {
    tmux split-window -h $"hx ($filepath)"
    tmux resize-pane -t 0 -x 35
  } else {
    tmux send-keys -t 1 $"\u{1b}\u{1b}:o ($filepath)" C-m
  }
}
