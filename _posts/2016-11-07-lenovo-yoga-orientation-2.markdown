---
layout: post
title:  "Lenovo Yoga 2 Orientation pt II"
date:   2016-11-07 12:28:15 +0000
categories: unix linux laptop
---
In my [last post][last-post] I was banging on about how I got my Yoga 2 to
auto-rotate and disable the touchpad when it did it. I made myself a runit
script to add it to startup and run as a daemon and to log the output.

However, I think there's a bug in the [yoga-laptop][yoga-laptop] repository
whereby on startup and resume from suspend (I'm not totally sure about where
this is manifesting just yet) where it will refuse to work, and on running
manually it transpires that the `orientation` binary is trying to pass "invalid"
to xrandr as an orientation. I assume that this is causing the `orientation`
binary to then shit itself and stop trying to parse.

I've not investigated yet - time's a premium at the moment - but I'm looking
forward to getting to the bottom of this.

[last-post]: {% post_url 2016-11-05-lenovo-yoga-orientation %}
[yoga-laptop]: https://github.com/pfps/yoga-laptop
