---
layout: post
title:  "SSL Shenanigans"
date:   2017-04-13 17:50:04 +0100
categories: SSL web
---

Due to StartSSL's CA StartCom being [distrusted by Apple, Google and
Mozilla][startcom_distrust] I went to use my [private url
shortener][grimmly_post] the other day to find that chrome wouldn't let me
because of my HSTS whilst using an untrusted cert.  This was particularly dumb
because they didn't give an override option, basically locking me out of viewing
my own site unless I unlocked the HSTS in chrome://net-internals

So I dutifully did that, making a mental note to switch over to letsencrypt.

Today I did that, and whilst I was at it I used the [SSLlabs
tester][grimmware_result] to get grimmwa.re from an F (because I kept building
my site from an old cached docker image - d'oh!) to an A+ with minimal effort.

I'll probably make an effort to open source my epic SSL Makefile at some point,
as it has pretty generic targets for generating standalone letsencrypt certs,
client certs and (more) secure Diffie-Hellman parameters.

[startcom_distrust]: https://security.googleblog.com/2016/10/distrusting-wosign-and-startcom.html
[grimmly_post]: {{ site.baseurl }}{% post_url 2017-03-29-Clever_me %}
[grimmware_result]: https://www.ssllabs.com/ssltest/analyze.html?d=grimmwa.re
