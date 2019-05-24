# journalctl  logs rotation

They had an overall size of ~5G (out of my 100G for /):
journalctl --disk-usage

The safest way to remove unessesary entries is via the journalctl:
journalctl --vacuum-size=128M
journalctl --vacuum-time=1d

After that you can verify if everything is still intact:
journalctl --verify

The config file for the journalctl lies under /etc/systemd/journald.conf. The following entry limits the size of your journal logs:
SystemMaxUse=128M

Another possible way could be:
SystemMaxFileSize=12M
SystemMaxFiles=10


Edit /etc/systemd/journald.conf to set SystemMaxUse=512M

sudo systemctl restart systemd-journald  ; sudo systemctl status  systemd-journald

