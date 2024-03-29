# PES Setup

[![GitHub stars](https://img.shields.io/github/stars/Pi-Entertainment-System/pes-setup)](https://github.com/Pi-Entertainment-System/pes-setup/stargazers) [![GitHub issues](https://img.shields.io/github/issues/Pi-Entertainment-System/pes-setup)](https://github.com/Pi-Entertainment-System/pes-setup/issues) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/Pi-Entertainment-System/pes-setup/ansible-lint.yml) [![GitHub license](https://img.shields.io/github/license/Pi-Entertainment-System/pes-setup)](https://github.com/Pi-Entertainment-System/pes-setup/blob/main/LICENSE)

Repository containing all the files and scripts required to set-up PES.

[Ansible](https://www.ansible.com/) is used to automate the installation of PES 3.0 for development and deployment.

PES uses [Arch Linux Arm](https://archlinuxarm.org/) and is available on the Raspberry Pi.

Pre-built images and user documentation can be found for PES 2.X at: https://pes.mundayweb.com

**Note:** PES 3.0 is under development

## Installation of Arch Linux

In all cases at least a 8GB SD card is required.

Create a 50MB fat32 partition followed by an ext4 partition of at at least 6GB.

Insert the SD card into your Linux system and proceed as follows, substituting the correct device as necessary.

### Raspberry Pi 2/3

```bash
mkdir root boot
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
mount /dev/sdf1 boot
mount /dev/sdf2 root
bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root
sync
mv root/boot/* boot/
```

### Raspberry Pi 4

```bash
mkdir root boot
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-armv7-latest.tar.gz
mount /dev/sdf1 boot
mount /dev/sdf2 root
bsdtar -xpf ArchLinuxARM-rpi-armv7-latest.tar.gz -C root
sync
mv root/boot/* boot/
```

### SSH modifcations

Whilst still mounted, edit `root/etc/ssh/sshd_config` and add:

```
PermitRootLogin yes
```

Now add your SSH key(s) to the root account in the image:

If you don't have any SSH keys set-up on your Linux host, make them now else skip this command:

```bash
ssh-keygen -t ed25519
```

Create `authorized_keys` file on Raspberry Pi file system:

```bash
cd root/root
mkdir .ssh
chmod 0700 .ssh
cp ~/.ssh/id_ed25519.pub .ssh/authorized_keys
chmod 0600 .ssh/authorized_keys
cd ../..
```

Finally:

```bash
umount boot
umount root
```

Now you can boot your Raspberry Pi.

## First Boot

Once your Raspberry Pi has booted, `ssh` in as root and run the following commands:

```bash
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu
reboot
```

## Import PES GPG keys

If you plan to use PES packages that have been signed, then import the key. For example, to import the GPG key used to sign official PES packages by Neil Munday:

```bash
pacman-key --recv-keys 48310703B4D7CD631162265274F5569D8E61676F
pacman-key --lsign 48310703B4D7CD631162265274F5569D8E61676F
```

## Set locale

Ansible requires a UTF8 locale to be set.

Edit `/etc/locale.gen` and uncomment `en_GB.UTF-8 UTF-8`.

Now run:

```bash
locale-gen
localectl set-locale en_GB.UTF-8
```

## Check out this Repository

```bash
pacman -S ansible git
git clone https://github.com/Pi-Entertainment-System/pes-setup
cd pes-setup
```

At this point you can enable WiFi if needed e.g.:

```bash
ansible-playbook -e 'wifi_psk=WIFI_PASSWORD wifi_ssid=WIFI_NETWORK' ansible/enable-wifi.yml
```

Set *WIFI_PASSWORD* and *WIFI_NETWORK* as necessary.

Now set-up Arch Linux for PES development:

```bash
ansible-playbook -i ansible/inventory ansible/dev-playbook.yml
```

After a successful run all of the packages required to build the PES packages will be installed.

## Raspberry Pi 4 Boot Loader Update

If you are using a Raspberry Pi 4, then the `rpi-eeprom` will have been installed. You can check if an update is available for your Raspberry Pi:

```bash
rpi-eeprom-update
```

Example output:

```
[root@alarmpi ~]# rpi-eeprom-update
*** UPDATE AVAILABLE ***
BOOTLOADER: update available
   CURRENT: Mon Jul 15 12:59:55 UTC 2019 (1563195595)
    LATEST: Thu Apr 29 16:11:25 UTC 2021 (1619712685)
   RELEASE: critical (/lib/firmware/raspberrypi/bootloader/critical)

  VL805_FW: Dedicated VL805 EEPROM
   VL805: update available
   CURRENT: 000137ad
    LATEST: 000138a1
```

If an update is available (as shown in the above example) then you can install it like so:

```bash
rpi-eeprom-update -a
reboot
```

## PES Packages

You can now build the packages required by PES. See: https://github.com/Pi-Entertainment-System/pes-packages/blob/main/README.md

Once built you can install the packages local by using `sudo pacman -U package_name.tar.xz`. However, it is advised to create a pacman repository on a web server that your Raspberry Pi to install packages from.

Note: an official PES packages repository will be publicly hosted at the time of the PES 3.0 release.

## Creating a Release Image of PES

PES on the Raspberry Pi is supplied as a Raspberry Pi image file that can be written to a SD card. When creating a PES set-up several development packages are installed by the Ansible `dev-playbook`. These are not needed by a PES installation once all packages have been built. The Ansible `setup-playbook` is intended to prepare a Raspbery Pi PES installation for image creation. It will for example uninstall development packages, delete unnecessary files, set-up the PES pacman repository etc.

```bash
ansible-playbook -i ansible/inventory -e pes_repo_url=URL_TO_PES_REPO ansible/setup-playbook.yml
```

If you do not specify `pes_repo_url`, the default value: https://pes.mundayweb.com/repo will be used.

Alternatively, you can create a fresh Arch Linux installation and use the above command to turn into a working PES set-up.
