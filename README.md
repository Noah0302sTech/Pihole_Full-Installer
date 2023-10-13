# Pihole_Full-Installer
A Full-Complete-Automatic Installer for Pihole, including optional Packages like Unbound, Keepalived and an automatic Pihole-Updater!

# How to Install
### SSH into your *clean* Debian-Server:
```bash
ssh username@ip
```
### Move to Home-Directory
```bash
cd
```
### Automatically download latest Full-Installer-Script and execute it (Need Sudo-Permissions)
```bash
wget https://raw.githubusercontent.com/Noah0302sTech/Pihole_Full-Installer/master/Debian/Pihole-Full-Installer-Debian-Noah0302sTech.sh && sudo bash Pihole-Full-Installer-Debian-Noah0302sTech.sh
```

**OR**

#### Go to Releases and follow the Instructions there

-----

## Known Issues:

At the end of the Installer, it will try to create the Directories, however they are already present, if you chose to install the Updater, Unbound or KeepAliveD.
**You can ignore the FAIL-Message!**
