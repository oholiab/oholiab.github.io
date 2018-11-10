---
layout: post
title:  "pidtree-bcc"
date:   2018-11-10 12:28:45 +0000
categories: security linux eBPF
---

Not that I let this blog know much of the machinations of my life, but
at the beginning of this year I switched over to a security role, and
it's been great.

One of the things which I've found to be a pain point is when ML based
network anomoly alerting tells us about hosts (especially our PaaS
hosts) making network connections that we as security engineers lack
the context to quickly triage.

As a hackathon project, I wrote [pidtree-bcc][pidtree-bcc] as a proof
of concept to show that we could use eBPF's syscall kprobes with some
added in-kernel filtering to trigger PID tree crawling in userland,
with the result that you can log the calling process tree for any
outbound connect syscalls.

For example, here's me pushing it to github:

```json
{
  "proctree": [
    [
      15808,
      "/usr/bin/ssh git@github.com git-receive-pack 'oholiab/pidtree-bcc'",
      "oholiab"
    ],
    [
      15807,
      "git push origin master",
      "oholiab"
    ],
    [
      31438,
      "-zsh",
      "oholiab"
    ],
    [
      696,
      "tmux",
      "oholiab"
    ],
    [
      1,
      "/usr/lib/systemd/systemd --system --deserialize 32",
      "root"
    ]
  ],
  "daddr": "140.82.118.4",
  "pid": 15808,
  "port": 22,
  "error": ""
}
```

This means a performant audit trail for network traffic.

I'd like to see if I can pull out cgroup context as well in order to
identify which service containers are originating the traffic so that
they can be profiled for better anomly-based alerting.

[pidtree-bcc]:https://github.com/oholiab/pidtree-bcc
