---
layout: post
title:  "Lenovo Yoga 2 Orientation"
date:   2016-11-05 17:25:15 +0000
categories: unix linux laptop
---
A couple of years ago I bought a Lenovo Yoga 2 11.6" laptop for general noodling
on (I didn't have a particularly portable personal laptop and I liked the idea
of playing around with a touchscreen laptop/tablet convertables).

Initially I set it up with Ubuntu 14.04 and had a whole puppet setup and it
worked pretty well, but there were a couple of problems - aside from the
slightly dodgy "Touchegg" for multitouch that couldn't seem to understand
certain gestures, I could never get the accelerometer working. I spelunked
around the Linux iio subsystem for a while (nfi what was going on there) and I
tried out pfps's [yoga-laptop][yoga-laptop] repo to no avail. I later installed
Void Linux and forgot all about the tablet functionality.

Today I went back down the rabbit hole to find that [yoga-laptop][yoga-laptop]
now works! I don't doubt it's a kernel upgrade or something within the past year
or so that's done it!

Using the `orientation` binary it figures out the right rotation and applies it,
and when the laptop is in tablet mode something in the hardware turns the
keyboard off, but the touch pad still works so I knocked this together:

```bash
HOMEDIR=/home/oholiab
ORIENTATION=$HOMEDIR/orientation-fifo
TOUCHSCREEN="Atmel Atmel maXTouch Digitizer"
TOUCHPAD="SynPS/2 Synaptics TouchPad"

mkfifo $ORIENTATION
unbuffer="stdbuf -i0 -o0 -e0"
($unbuffer orientation --debug=0 --usleep=500000 --touchscreen="$TOUCHSCREEN" | $unbuffer awk '/ROTATE/ { print $3 }' > $ORIENTATION)&
orientation_pid=$!
orientation_pidfile=$HOMEDIR/orientation.pid
echo $orientation_pid > $orientation_pidfile

function cleanup {
  kill $orientation_pid
  rm $orientation_pidfile
  rm $ORIENTATION
  exit
}

trap cleanup SIGINT SIGTERM SIGHUP

last_orientation=
while read orientation; do
  echo $orientation
  [ "$orientation" = "$last_orientation" ] && continue
  [ "$orientation" != "normal" ] && xinput disable "$TOUCHPAD"
  [ "$orientation" = "normal" ] && xinput enable "$TOUCHPAD"
  last_orientation=$orientation
done < $ORIENTATION
```

It's a little shonky but it does the trick! The most difficult part was figuring
out the `$unbuffer` section and that it has to be repeated in pipes or the
output never makes it through in time!

I'm going to have a go at installing an onscreen keyboard and a multitouch
interpreter again.

[yoga-laptop]: https://github.com/pfps/yoga-laptop
