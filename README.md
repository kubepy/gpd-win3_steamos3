# gpd-win3_steamos3

`HoloISO_4.5-rc1_beta-candidate-20230324_d1cc6e5738_intel_mesa_changes-1-x86_64.iso`

After installed, chroot to disable default gamescope startup.
```
holoiso-disable-sessions
```

Control CPUFreq 70%~80% for increasing GPU performance.

### install `plasma-pstate` wiget for KDE desktop.
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

### `gamescope-session` script change to `DSI-1`, `-w 1280 -h 720`, `sleep 6`.
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

### settings (likely requires 16G+8G ) swap for hibernating, (recommended to 32G) 

#### create the swap partition or swap file and edit `/etc/fstab`, advoing use `/home` dir because systemd permission.
#### If use the `/home` directory please confirm the issue (https://github.com/systemd/systemd/issues/15354) `systemd-logind.service`

```
[Service]
ProtectHome=read-only
```
Or
```
[Service]                                                                                                   
Environment=SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK=1
```

#### append `resume=UUID=ddf7dfaf-98c0-4ad1-b1b4-d78c63113b88` UUID wit the swap partition arg to grub. For swapfile it needs append `resume_offset`
#### resume_offset address could use `filefrag -v swapfile` to find
#### sudo btrfs inspect-internal map-swapfile -r swapfile to find

```
        GRUB_CMDLINE_LINUX_DEFAULT="fbcon=rotate:1 video=DSI-1:panel_orientation=right_side_up mem_sleep_default=s2idle resume=UUID=ddf7dfaf-98c0-4ad1-b1b4-d78c63113b88 quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0"
```
```
holoiso-grub-update
```

#### append `resume` arg to `/etc/mkinitcpio.conf`.

```
vim /etc/mkinitcpio.conf
```

```
HOOKS=(base udev autodetect modconf block filesystems keyboard resume fsck)
```

```
sudo mkinitcpio -P
```

#### gamescope mode for hibernate, edit `vim /usr/lib/hwsupport/power-button-handler.py` for appending this contents.
#### The var `powerbuttondev` need to specify the input device, gpd win3 is `/dev/input/event2` for power key.
#### `sudo usermod -a -G input deck` is `required` if the deck user cannot read the input device without the root permission.
```
dev_path = '/dev/input/event2'
powerbuttondev = evdev.InputDevice(dev_path)
```

Also can sort the event id for selecting the first one.
```
# sort the event id and match the first one
devices.sort(key=lambda device: int(device.path[-1]))
found = False
for device in devices:
    if device.name == "Power Button" and not found:
        print (device)
        powerbuttondev = device;
        found = True
    else:
        device.close()
```

Input devices permission setup for deck user, then `systemctl reboot`, it should work after `reboot`.
```
sudo usermod -a -G input deck
```

then edit the if case, changed to `os.system( "/usr/bin/systemctl hibernate" )`
```
		if event.type == evdev.ecodes.EV_KEY and event.code == 116: # KEY_POWER
			if event.value == 1:
				longpresstimer = threading.Timer( 1.0, longpress )
				longpresstimer.start()
			elif event.value == 0:
				if longpresstimer != None:
					os.system( "/usr/bin/systemctl hibernate" )
					#os.system( "~/.steam/root/ubuntu12_32/steam -ifrunning steam://shortpowerpress" )
					longpresstimer.cancel()
					longpresstimer = None
```

power buttn input device could use `sudo cat /proc/bus/input/devices` or `sudo udevadm info /dev/input/eventX` to check
for testing the button `event` or `value`, use `sudo evtest` command

```
# sudo evtest
No device specified, trying to scan all of /dev/input/event*
Available devices:
/dev/input/event0:	Lid Switch
/dev/input/event1:	Sleep Button
/dev/input/event10:	Goodix Capacitive TouchScreen
/dev/input/event11:	  Mouse for Windows
/dev/input/event12:	gpio-keys
/dev/input/event13:	  Mouse for Windows
/dev/input/event14:	Video Bus
/dev/input/event15:	Microsoft X-Box 360 pad
/dev/input/event16:	HDA Intel PCH Mic
/dev/input/event17:	HDA Intel PCH Headphone
/dev/input/event18:	HDA Intel PCH HDMI/DP,pcm=3
/dev/input/event19:	HDA Intel PCH HDMI/DP,pcm=7
/dev/input/event2:	Power Button
/dev/input/event20:	HDA Intel PCH HDMI/DP,pcm=8
/dev/input/event21:	HDA Intel PCH HDMI/DP,pcm=9
/dev/input/event3:	Power Button
/dev/input/event4:	Intel HID events
/dev/input/event5:	Intel HID 5 button array
/dev/input/event6:	PC Speaker
/dev/input/event7:	SINO WEALTH 唰匀䈀 䬀攀礀戀漀愀爀搀
/dev/input/event8:	SINO WEALTH 唰匀䈀 䬀攀礀戀漀愀爀搀 Mouse
/dev/input/event9:	SINO WEALTH 唰匀䈀 䬀攀礀戀漀愀爀搀 Consumer Control
```
push 2 for `/dev/input/event2:	Power Button`
```
Select the device event number [0-21]: 2
Input driver version is 1.0.1
Input device ID: bus 0x19 vendor 0x0 product 0x1 version 0x0
Input device name: "Power Button"
Supported events:
  Event type 0 (EV_SYN)
  Event type 1 (EV_KEY)
    Event code 116 (KEY_POWER)
Properties:
Testing ... (interrupt to exit)	
```

push the power bottun will print, it knows the device is `/dev/input/event2` and the is code `116` and the `value` is `1` or `0`
```
Event: time 1680525622.223988, type 1 (EV_KEY), code 116 (KEY_POWER), value 1
Event: time 1680525622.223988, -------------- SYN_REPORT ------------
Event: time 1680525622.224007, type 1 (EV_KEY), code 116 (KEY_POWER), value 0
Event: time 1680525622.224007, -------------- SYN_REPORT ------------
```
