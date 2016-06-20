# niXmonad
nixos x xmonad

To set up an xmonad wm virtualbox dev machine:

create VM, boot with nixos iso (see for details: https://nixos.org/wiki/Installing_NixOS_in_a_VirtualBox_guest)

```bash
$ fdisk /dev/sda # Create a full partition, For quick setup use these commands in order: n, p, 1, <Enter>, <Enter>, w
$ mkfs.ext4 -j -L nixos /dev/sda1
$ mount LABEL=nixos /mnt
$ nixos-generate-config --root /mnt
```

clone the repo
```
$ nix-env -e git
$ cd /etc
$ mv nixos nixos.bkup
$ git clone https://github.com/pkinsky/niXmonad.git nixos # replace hardware.nix w/ generated one in nixos.bkup
$ nixos-install
$ reboot
```

that's the goal, anyway. It's a work in progress
