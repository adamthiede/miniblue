# How-To:

1. Install a Fedora Atomic os. Preferably the [sway](https://fedoraproject.org/atomic-desktops/sway/download/) one, since it's small and lets you create a user during setup.

```
sudo ostree admin pin 0
```

2. Rebase to the image and reboot

```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/adamthiede/miniblue:latest
sudo reboot
```

3. Rebase to the image again, after it's trusted.

```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/adamthiede/miniblue:latest
sudo reboot
```

