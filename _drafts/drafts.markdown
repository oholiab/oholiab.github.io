#UEFI
The current subgraph alpha ISO doesn't actually have support for installing UEFI
grub, so it's necessary to suck up the failed grub install and then reboot into
the live distro again in order to fix it. This was made harder by the fact that
I'd installed on an encrypted LVM so couldn't straight up mount the drive...

So tl;dr: I followed these this stackoverflow post on mounting an encrypted LVM
partition and this github comment on installing grub to the UEFI partion

Of particular note is that Subgraph's Debian installer made the UEFI partition
for me, it just didn't have the software available (through not having set up
the networking and therefore I couldn't just pop open a shell to install it
during the process) to actually install grub to it.

#How to do it

...

Installing the packages gave me an interactive prompt for installing to selected
devices - for the sake of simplicity (and I suppose repeatablilty), I didn't
select any and skipped it so that I could do it manually.

#Things that need documenting
* Lack of UEFI support (and how to fix it)
* That it is a) only single user and b) that user's name has to be "user"

#Things that can do with removing
* libreoffice

#Things to be aware of
* `apt upgrade` is pretty big - probably needs doing straight off the bat but
  takes time as it's over tor. Keep an eye out for Tor and wireless dropouts
* Wireless and Tor can drop out without you noticing ending in confusion

#Things that are definitely broken
* Default tor browser install does not work..
  * Go to https://github.com/micahflee/torbrowser-launcher/blob/master/BUILD.md
    and follow instructions
  * Before the `dpkg -i` do `sudo oz-setup remove torbrowser-launcher` and after
    do `sudo oz-setup install torbrowser-launcher`
* Password change is fucked - it thinks everything is a common word
