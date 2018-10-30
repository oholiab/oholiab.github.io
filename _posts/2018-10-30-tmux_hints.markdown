---
layout: post
title:  "tmux hints"
date:   2018-10-30 12:06:48 +0000
categories:
---
> Terminal UI hints using tmux formatting

Long time no post.

I've been playing around with making a basic framework around systemd-nspawn and creating ephemeral and persistent contaiers using overlayfs for various reasons (shits AND giggles). Very much inspired by the way that both Realms in Subgraph Citadel and Oz in it's predecessor Subgraph OS, I wanted to emulate the ability to have visual hints of which container I had a terminal spawned in.

The way that those other systems do it is using formatting for whichever terminal, and having that saved inside the container. One of the problems with this is that a) something inside the container can change it and b) multiple terminal windows suck, use tmux you filthy casual.

So in my system, written in bash because please don't hate on me you have to start somewhere, I've added a couple of helper functions to wrap the session in:

```bash
function hilight_pane {
  if [ "x$TMUX_PANE" != "x" ]; then
    tmux select-pane -t $TMUX_PANE -P 'bg=#222222'
  fi
}

function dehilight_pane {
  if [ "x$TMUX_PANE" != "x" ]; then
    tmux select-pane -t $TMUX_PANE -P 'bg=default'
  fi
}
```

which you can invoke thusly when you're at the beginning of whatever script you're writing:

```bash
trap dehilight_pane EXIT
hilight_pane
```

Which will cause the current tmux pane to have a dark gray background for the duration of your script, and return to default on exit. If you're not in a tmux session, it will do nothing :)

And yes I write hilight weird.
