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

todo:
- script such that setup is reduced to eval $(wget x.co/abcd.sh) or similar
