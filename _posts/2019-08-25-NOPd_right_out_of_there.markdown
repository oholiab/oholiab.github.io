---
layout: post
title:  "NOPd right out of there: Controlling `rip`"
date:   2019-08-25 15:36:22 +0100
categories: reversing NOP shellcode exploits security
---

Hey. Been a while.

Thanks to a friend stopping by before CCC, I've been working on a CTF challenge, and I'm learning an absolute shitload. The CTF challenge is still live, so I won't namedrop it but owing to the fact nobody reads this shit anyway I figure I can go deep on a few things that I've learned. 

Rather than attempt to write everything at once in one place I'm going to just blog the bits as I have time and think of them and then link them all together later as a cheat sheet of "shit you might not know because Google doesn't work properly any more".

# Overflowing x86_64 return address
Firstly, I'm learning some interesting things with regards to the way that people post tutorials online about writing shellcode: they post it for x86 despite the fact nobody's using 32 bit Intel any more. An absolutely *huge* deal here is that when you're trying to overflow `rip` (`eip` in nobody-cares-anymore-that-shit-is-old land) the valid address range is *not* typically 64bit. To shamelessly copy the explanation from [here][64bit explanation] ([archived][archived 64bit explanation]) because the Wikipedia text it's referencing is now gone...:

> In a 64-bit architecture, the entire 2⁶⁴ bytes are not utilized for
> address space. In a typical 48 bit implementation, canonical address
> refers to one in the range 0x0000000000000000 to 0x00007FFFFFFFFFFF
> and 0xFFFF800000000000 to 0xFFFFFFFFFFFFFFFF. Any address outside this
> range is non-canonical.

What this means practically is after you've demonstrated to yourself that you've managed to get the thing to segfault and you know what the offset to overflow `rsp` is (e.g. in `gdb` you can see your oveflow pattern in `rsp` with `inspect registers`) you'll need the next 8 bytes in your overflow pattern to be addressable. I know that sounds pretty fucking obvious, but coming to it obliquely with your first practical attempt, you might wonder why it keeps SEGFAULTing on return - it's because on function return the CPU is trying to jam `0x4141414141414141` or whatever your overflow pattern is from the stack return address into `rip` which won't accept the value. 

This can be hugely misleading because as a newbie (like I was) you won't know that you *are* overflowing the return address, it's just that after the `return` the processor can't `mov` it into `rip` so it looks like you haven't overflowed.

# Next up
We'll be talking about stack execution protection

[64bit explanation]:https://medium.com/@buff3r/basic-buffer-overflow-on-64-bit-architecture-3fb74bab3558
[archived 64bit explanation]:https://web.archive.org/save/https://medium.com/@buff3r/basic-buffer-overflow-on-64-bit-architecture-3fb74bab3558
