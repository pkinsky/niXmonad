# niXmonad
nixos x xmonad

To set up an xmonad wm virtualbox dev machine:

create VM, boot with nixos iso (see for details: https://nixos.org/wiki/Installing_NixOS_in_a_VirtualBox_guest)

```bash
fdisk /dev/sda # Create a full partition, For quick setup use these commands in order: n, p, 1, <Enter>, <Enter>, w
mkfs.ext4 -j -L nixos /dev/sda1
mount LABEL=nixos /mnt
nixos-generate-config --root /mnt
```

clone the repo
```bash
nix-env -i git
cd /mnt/etc
mv nixos nixos.bkup
git clone https://github.com/pkinsky/niXmonad.git nixos
cp nixos.bkup/hardware-configuration.nix nixos/
nixos-install
reboot
```

log in as root using the password you just chose and run

```bash
passwd pkinsky
```

then login as pkinsky w/ your new password


ISSUES:
. xrdb/etc stuff seems not to work on fresh install. possibly due to using nix-managed xmonad dir instead of git-cloned mutable one in home dir on fresh install
.. may not be able to have actual xmonad git dir managed directly in xmonad
.. maybe more fine-grained linking? link in xmonad.hs, xresources, but not the actual directory
