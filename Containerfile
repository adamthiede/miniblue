ARG FEDORA=43
ARG FROM
FROM quay.io/fedora-ostree-desktops/base-atomic:${FEDORA}

COPY dnf.conf /etc/dnf/dnf.conf

# rpmfusion, override removes
RUN	dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" && \
	dnf install -y rpmfusion-free-release-tainted && \
	dnf install -y --allowerasing vim-default-editor fedora-release-identity-cinnamon ffmpeg && \
	dnf install -y \
		xorg-x11-drv-intel xorg-x11-drv-amdgpu xorg-x11-drv-libinput xorg-x11-drv-nouveau xorg-x11-drv-qxl xorg-x11-drv-vmware xorg-x11-drv-evdev \
		libva-intel-media-driver libva-utils \
		cinnamon cinnamon-desktop cinnamon-session cinnamon-settings-daemon cinnamon-menus cinnamon-control-center cinnamon-themes mint-themes mint-y-icons nemo \
		sddm \
		libdvdcss \
		libva-intel-driver \
		intel-media-driver \
		gnome-themes-extra \
		fastfetch \
		libreoffice-writer libreoffice-calc libreoffice-impress \
		vlc \
		gnome-terminal \
		xed \
		&& \
	dnf remove -y \
		virtualbox-guest-additions \
		default-fonts-core-emoji google-noto-color-emoji-fonts google-noto-emoji-fonts \
		&& \
	ostree container commit

COPY ostree-notify/ostree-notify.sh /usr/bin/ostree-notify.sh
COPY ostree-notify/ostree-notify.timer /etc/systemd/user/ostree-notify.timer
COPY ostree-notify/ostree-notify.service /etc/systemd/user/ostree-notify.service
COPY update-flatpak/update-flatpak.timer /etc/systemd/system/update-flatpak.timer
COPY update-flatpak/update-flatpak.service /etc/systemd/system/update-flatpak.service

# doesn't work yet
# COPY policy.json /etc/containers/policy.json
COPY cosign.pub /etc/pki/containers/miniblue.pub
COPY desktop-readme.txt /etc/skel/Desktop/README.txt

RUN mkdir -p /var/lib/alternatives && \
    echo -e "[Daemon]\nAutomaticUpdatePolicy=stage\n" > /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl disable NetworkManager-wait-online.service && \
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
    ln -s /etc/systemd/user/ostree-notify.timer /etc/systemd/user/default.target.wants/ && \
	systemctl enable update-flatpak.timer && \
    rm -f /usr/share/wayland-sessions/cinnamon* && \
    ostree container commit
