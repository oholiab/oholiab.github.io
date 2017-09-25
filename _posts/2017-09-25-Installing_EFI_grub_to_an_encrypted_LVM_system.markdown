---
layout: post
title:  "Installing EFI grub to an encrypted LVM system"
date:   2017-09-25 12:46:55 +0100
categories: debian EFI yak-shaving
---
When I was installing subgraphOS alpha3 (fear not, there's a [new
release][newrelease] out that I've tested and installed which fixes this
problem!) there was no grub installer for UEFI in the OS installer, meaning that
I had to skip the grub install, reboot to the live OS, remount the encrypted
LVM, install the grub package in the chrooted environment and then install grub
to the efi partition.

Whilst it's not necessary any more due to the new release, I documented the
thing whilst I was going based on this [github issue comment][github] and this
[stackoverflow post][stackoverflow] just for anyone who has problems getting
grub installed on an encrypted LVM install of a debian based system (which is
sadly probably more likely than it sounds)

## Mounting encrypted LVM

Boot to a live distribution and open a root shell in /, and list available block
devices:

```bash
root@subgraph:/# ls
bin  boot  dev	etc  home  lib	lib64  media  mnt  opt	proc  root  run  sbin  srv  sys  tmp  usr  var
root@subgraph:/# lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0    7:0    0   1.1G  1 loop /lib/live/mount/rootfs/filesystem.squashfs
sda      8:0    0 119.2G  0 disk 
├─sda1   8:1    0   512M  0 part 
├─sda2   8:2    0   244M  0 part 
└─sda3   8:3    0 118.5G  0 part 
sdb      8:16   1  57.7G  0 disk 
├─sdb1   8:17   1   1.3G  0 part /lib/live/mount/medium
├─sdb2   8:18   1   704K  0 part 
└─sdb3   8:19   1  56.4G  0 part /media/user/Subgraph live 12302016
```

In this example, I'm booted from `/dev/sdb` and I want to read an LVM volume on
`/dev/sda3`. As it stands, I can't mount `/dev/sda3` because it's encrypted LVM:

```bash
root@subgraph:/# mount /dev/sda3 /mnt
mount: unknown filesystem type 'crypto_LUKS'
```

### Install the tools and load the kernel module
So I update my apt cache and I install the approriate tools... `lvm2` and
`cryptsetup`:

```bash
root@subgraph:/# apt-get update
Ign:1 tor+http://cdn-fastly.deb.debian.org/debian stretch InRelease                                                 
Get:2 tor+http://cdn-fastly.deb.debian.org/debian stretch-updates InRelease [91.0 kB]                               
... <snip>
root@subgraph:/# apt install lvm2 cryptsetup
Reading package lists... Done
...<blah blah blah>
```

Now we have the tools, all we have to do is enable the kernel module for working
with the encrypted filesystem. I also double check with `fdisk` that I'm looking
at the partitions that I'm expecting, and I am indeed looking for the stuff on
`sda`:

```bash
root@subgraph:/# modprobe dm-crypt
root@subgraph:/# fdisk -l
Disk /dev/sda: 119.2 GiB, 128035676160 bytes, 250069680 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 75985EEA-BDE6-4936-B5CE-ABCB80B697CF

Device       Start       End   Sectors   Size Type
/dev/sda1     2048   1050623   1048576   512M EFI System
/dev/sda2  1050624   1550335    499712   244M Linux filesystem
/dev/sda3  1550336 250068991 248518656 118.5G Linux filesystem


Disk /dev/sdb: 57.7 GiB, 61951967232 bytes, 120999936 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xb9f171e3

Device     Boot   Start       End   Sectors  Size Id Type
/dev/sdb1  *         64   2684351   2684288  1.3G  0 Empty
/dev/sdb2          5060      6467      1408  704K ef EFI (FAT-12/16/32)
/dev/sdb3       2684928 120999935 118315008 56.4G 83 Linux


Disk /dev/loop0: 1.1 GiB, 1148309504 bytes, 2242792 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

### Load the keys to decrypt the LVM partition

Now we load the decryption key for `sda3` into memory, scan for the logical
volumes inside the LVM, and mount the one we're after:

```bash
root@subgraph:/# cryptsetup luksOpen /dev/sda3 myvolume
Enter passphrase for /dev/sda3: 
root@subgraph:/# vgscan
  Reading volume groups from cache.
  Found volume group "subgraph-vg" using metadata type lvm2
root@subgraph:/# vgchange -ay subgraph-vg
  2 logical volume(s) in volume group "subgraph-vg" now active
root@subgraph:/# lvs
  LV     VG          Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   subgraph-vg -wi-a----- 114.60g                                                    
  swap_1 subgraph-vg -wi-a-----   3.90g                                                    
root@subgraph:/# mount /dev/subgraph-vg/root /mnt
```

If you're just after getting access to your encrypted data you can stop here -
however what we're interested in is installing grub to the efi partition, a
capability which was missing from the SubgraphOS alpha3 installer.

### Installing UEFI grub

The goal here is to reconstruct `/`, `/boot` and `/boot/efi` to install to on
mount so we can chroot into it, so as well as mounting the encrypted LVM
partition for `/` on to `/mnt`, we also mount the unencrypted boot and EFI
partitions on top of that, and then bind mount the various pseudo filesystems
needed to function from the running host OS:

```bash
root@subgraph:/# mount /dev/sda2 /mnt/boot
root@subgraph:/# mount /dev/sda1 /mnt/boot/efi
root@subgraph:/# for i in /dev /dev/pts /proc /sys /run; do sudo mount --bind $i /mnt$i; done
```

Now we can chroot in and pretend we're in our install rather than on our live
distribution. From here we're going to install the missing grub packages and use
these to make our system bootable:

```
root@subgraph:/# chroot /mnt
root@subgraph:/# ls
bin  boot  dev	etc  home  lib	lib64  lost+found  media  mnt  opt  proc  root	run  sbin  srv	sys  tmp  usr  var
root@subgraph:/# apt-get update
... <yep, we have to do this again - the installed system doesn't have an updated apt-cache yet!>
root@subgraph:/# apt-get install grub-efi-amd64-bin efibootmgr
... <install happens>
```

Finally we can do a grub-install to make our system bootable!

```
root@subgraph:/# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=subgraph /dev/sda
Installing for x86_64-efi platform.
Installation finished. No error reported.
root@subgraph:/# update-grub
Generating grub configuration file ...
Found background image: .background_cache.png
Found linux image: /boot/vmlinuz-4.8.15-grsec-amd64
Found initrd image: /boot/initrd.img-4.8.15-grsec-amd64
Adding boot menu entry for EFI firmware configuration
done
root@subgraph:/# 
```
Now you can exit your chroot and reboot the system!

[github]:https://github.com/subgraph/subgraph-os-issues/issues/192#issuecomment-297552836
[stackoverflow]:https://askubuntu.com/a/653460
[newrelease]:https://subgraph.com/sgos/download/index.en.html
