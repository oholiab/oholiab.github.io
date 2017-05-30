---
layout: post
title:  "Spacemacs"
date:   2017-05-30 17:41:23 +0100
categories: software editors coding
---

![I feel like a shill]({ site.images_baseurl }/spacemacs.png)

I might have mentioned before that I like writing shit in Clojure for what
aren't particularly good reasons. In doing so, I've become kind of fond of
[Spacemacs][spacemacs]. I like it for the interactivity with the REPL, lisp
mode, vim editing mode and just the general way its set up.

Well today I decided to try it out with Ruby, and was really nicely surprised as
it led to me finding an easy way to selectively run [beaker][beaker] tests
without having to a) run them all or b) figure out the invocation by myself.
This is really awesome because beaker tests take an age, especially if you're
testing puppet code.

[spacemacs]: http://spacemacs.org/
[beaker]: https://github.com/puppetlabs/beaker
