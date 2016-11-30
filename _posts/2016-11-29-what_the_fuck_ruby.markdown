---
layout: post
title:  "what the fuck ruby."
date:   2016-11-29 16:07:11 -0800
categories: blog ruby jekyll
---

I found a fun feature of ruby today. Whilst writing some helper code for
generating posts for [my blog][blog-code], I created a script (imaginatively)
named `helpers`. To run it, you just do `bundle exec helpers <command>` where
the only command (currently) is `post`. To make things even simpler, I added it
to my Makefile so you just run `make post` and have done with it.

The script asks you what the title of your post is going to be so that it can
generate the Jekyll front matter, for which I used `gets`. Little did I know
that the default behaviour of gets is NOT to take input from STDIN if there is
an argument, but to try and take it from the "file" in `ARGV[0]`. Like so:

```
> cat test.rb
#!/usr/bin/env ruby
gets
> ./test.rb
alskdfjlaskdfjsldfj
> ./test.rb lsakdfjasldkfj
./test.rb:2:in `gets': No such file or directory @ rb_sysopen - lsakdfjasldkfj
(Errno::ENOENT)
        from ./test.rb:2:in `gets'
        from ./test.rb:2:in `<main>'
```

I like writing ruby because I find it fun, expressive and powerful but god damn
that's fucking stupid. This is why I don't have any heroes.

`STDIN.gets` it is then.

[blog-code]: https://github.com/oholiab/oholiab.github.io
