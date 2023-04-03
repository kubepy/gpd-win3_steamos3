# gpd-win3_steamos3


Control CPUFreq 70%~80% for increasing GPU performance.

### install plasma-pstate wiget for KDE desktop.
```
pacman -S cmake extra-cmake-modules base-devel
git clone https://github.com/frankenfruity/plasma-pstate
cd plasma-pstate
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=Release ..
make
sudo make install
```

### gamescope-session change to DSI-1, -w 1280 -h 720, sleep 6.
```
gamescope \
	--generate-drm-mode fixed \
	--xwayland-count 2 \
	-w 1280 -h 720 \
	--default-touch-mode 4 \
	--hide-cursor-delay 3000 \
	--max-scale 2 \
	--fade-out-duration 200 \
	-e -R "$socket" -T "$stats" \
	-O '*',DSI-1 \
	--force-orientation right \
	-f \
	--cursor-hotspot 5,3 --cursor /usr/share/steamos/steamos-cursor.png \
	&
gamescope_pid="$!"

sleep 6
```

### settings 32G swap for hibernating

#### create the swap partition or swap file, advoing use /home dir because systemd permission. If use the /home directory please confirm the issue (https://github.com/systemd/systemd/issues/15354)

```
[Service]
ProtectHome=read-only
```
Or
```
[Service]                                                                                                   
Environment=SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK=1
```

#### append `resume=UUID=ddf7dfaf-98c0-4ad1-b1b4-d78c63113b88` UUID wit the swap partition arg to grub
```
        GRUB_CMDLINE_LINUX_DEFAULT="fbcon=rotate:1 video=DSI-1:panel_orientation=right_side_up mem_sleep_default=s2idle resume=UUID=ddf7dfaf-98c0-4ad1-b1b4-d78c63113b88 quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0"
```

#### append `resume` arg to /etc/mkinitcpio.conf

```
vim /etc/mkinitcpio.conf
```

```
HOOKS=(base udev autodetect modconf block filesystems keyboard resume fsck)
```

```
sudo mkinitcpio -P
```
