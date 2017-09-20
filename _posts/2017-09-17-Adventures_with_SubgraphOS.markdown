---
layout: post
title:  "Adventures with SubgraphOS"
date:   2017-09-17 14:28:21 +0100
categories: security OS privacy subgraphOS
---

![SubgraphOS's mostly out-of-date but still very cool concept diagram]({{ site.images_baseurl }}/sgos.png)

After going to [44CON][44con] last week, my brain's been buzzing with a bunch of
things. One of them is [SubgraphOS][subgraph], which is a Linux distribution
focussing on adversary resistant computing. It utilizes a hardened kernel
([grsecurity/PaX][grsecurity] and has a bunch of the more esoteric driver
support ripped out to reduce the attack cross section), app sandboxing via
[oz][oz], syscall profiling and restriction using BPF and per-application
firewalling a la [Little Snitch][littlesnitch].

Additionally, there are some bonus features not yet included in the current
release (alpha3) which I've been playing around with - most notably their change
in tack from the "route everything through tor" strategy to per-sandbox routing
through things like Tor, i2p and OpenVPN.

Part of the appeal for me is just knowing (and restricting) what I'm actually
allowing my computer to do - it's a key part of privacy and has application in
infrastructure security as well as personal computing security.

I'll (hopefully) be putting together a few little things on what I've been doing
and how I did it, as this OS is very much in alpha and I'd like to be able to
contribute to the direction it goes in.

[44con]:https://44con.com/
[subgraph]:https://subgraph.com/sgos/
[grsecurity]:https://en.wikipedia.org/wiki/Grsecurity
[oz]:https://github.com/subgraph/oz
[littlesnitch]:https://www.obdev.at/products/littlesnitch/index.html
