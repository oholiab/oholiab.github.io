---
layout: post
title:  "God forbid you change your search engine"
date:   2019-09-03 14:33:52 +0100
categories: web browsers search Google firefox
---
# The stupid problem
At work, for my sins and whatever reasons, I use Google search. Now if you want to find articles about how Google search has suddenly and magically become entirely shit, you can (hilariously) Google for them. Personally I have my theories which I'm pretty sure that nobody cares about, but I finally decided today that I would change my default search to Google's "Verbatim" search so it wouldn't drop so many of my search terms in some attempt to be "helpful" (or homogenizing).

So you'd think this would be easy in Firefox. Turns out it's really fucking not. In the most hilarious affront to claims of being the browser of the open web, the json configuration that determines these settings is in fact lz4 compressed with some weird little Mozilla-custom header so `lz4` can't actually decompress it for "historical reasons" that are altogether entirely uninteresting.

So, of course, piecing together tidbits of advice from others on the internet, here's how you make "Verbatim" search your default:

# Decompress your search.json.mozlz4
Firstly, trimming the first 8 bytes with `dd` and then using `lz4` to decompress *does not work*. Probably something something block something, but basically I wanted the job done so:

## Prerequisites
Install `lz4` via pip and `jq` via your package manager.

## Code
```python3
#/usr/bin/env python3

import lz4.block as lb
import sys

compress_mode = False
infile = sys.stdin.buffer
if len(sys.argv) > 1:
    if sys.argv[1] == "-c":
        compress_mode = True
if compress_mode:
    data = lb.compress(infile.read())
    data = b'mozLz40\0' + data
    sys.stdout.buffer.write(data)
else:
    infile.read(8)
    data = lb.decompress(infile.read())
    sys.stdout.write(data.decode("utf-8"))
    print("")
```

Put that in a file named `mozlz4` and put it in your `PATH` and `chmod 755`.

## Doing the dirty
Change directory to wherever your `search.json.mozlz4` file is - for me this was `~/Library/Application\ Support/Firefox/Profiles/<some_shit>/`

Then you can decompress your file with:

```bash
mozlz4 < search.json.mozlz4 | jq . > search.json
```

Edit your `search.json` to add another entry for `params` under the `engines` entry with `"_name": "Google"` such that:

```json
"params": [
  {
    "name": "q",
    "value": "{searchTerms}"
  }
]
```
(there might have been another query string in here that told Google that I was using Firefox which I deleted and I don't know what it was now)

reads:
```json
"params": [
  {
    "name": "q",
    "value": "{searchTerms}"
  },
  {
    "name": "tbs",
    "value": "li:1"
  }
]
```

This basically just adds the query string parameter `tbs=li:1` which sets "Verbatim" mode.

Now finally you just need to recompress the file:

```bash
jq -c -r . < search.json | mozlz4 -c > newsearch.json.mozlz4
```

Here, `jq -c -r .` strips all the whitespace and pretty-printing.

Inspect your new file and if you're happy with it, quit all Firefox instances, `mv newsearch.json.mozlz4 search.json.mozlz4` and enjoy.

# Conclusion
Working as a security engineer, I can totally understand why you might not want to encourage "The Muggles" to futz about adding arbitrary query strings to their search engines because some mook on the internet told them too. However, requiring that you can first figure out the file format, bump off the first 8 bytes, decompress it, edit and then recompress (or alternatively install some rando third party plugin) to change the way your search functions is precisely *how* we end up with the technocracy controlling what everyone does on the web.

I'm really disappointed with Moz here. All I want to do is get some control back over how I search, because it's becoming increasingly difficult to find things if you know what you're looking for. Were this just a `json` file, I'd be fine with it - fundamentally it would be a stepping stone for people to learn to control the tech they use, and it would be an introduction to a fundamental web technology. You'd be encouraging people to tinker under the hood of a ubiquitious technology. As it stands, you need to do a bunch of arcane shit or install a third party utility to do something that the priesthood have not deigned "core functionality", and that's not okay.
