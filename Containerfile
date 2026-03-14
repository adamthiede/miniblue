ARG FEDORA
ARG FROM=43
FROM quay.io/fedora-ostree-desktops/base-atomic:${FEDORA}

RUN	rpm-ostree install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" && \
	rpm-ostree install "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" && \
	rpm-ostree install rpmfusion-free-release-tainted && \
	rpm-ostree override remove \
		ffmpeg-free \
		libavcodec-free \
		libavdevice-free \
		libavfilter-free \
		libavformat-free \
		libavutil-free \
		libpostproc-free \
		libswresample-free \
		libswscale-free \
		virtualbox-guest-additions \
		nano nano-default-editor \
		default-fonts-core-emoji google-noto-color-emoji-fonts google-noto-emoji-fonts \
		--install vim-default-editor \
		--install ffmpeg && \
	rpm-ostree install \
		cinnamon-desktop cinnamon-session cinnamon-settings-daemon cinnamon-menus cinnamon-control-center nemo papers \
		lightdm-gtk slick-greeter \
		xorg-x11-drv-intel xorg-x11-drv-amdgpu xorg-x11-drv-libinput xorg-x11-drv-nouveau xorg-x11-drv-qxl \
		libva-intel-media-driver libva-utils \
		libdvdcss \
		libva-intel-driver \
		intel-media-driver \
		tailscale \
		NetworkManager-tui \
		gvfs-nfs \
		syncthing \
		gnome-themes-extra \
		distrobox \
		fastfetch \
		htop \
		&& \
	ostree container commit

COPY ostree-notify/ostree-notify.sh /usr/bin/ostree-notify.sh
COPY ostree-notify/ostree-notify.timer /etc/systemd/user/ostree-notify.timer
COPY ostree-notify/ostree-notify.service /etc/systemd/user/ostree-notify.service
COPY update-flatpak/update-flatpak.timer /etc/systemd/system/update-flatpak.timer
COPY update-flatpak/update-flatpak.service /etc/systemd/system/update-flatpak.service

COPY policy.json /etc/containers/policy.json
COPY cosign.pub /etc/pki/containers/cosign.pub

RUN mkdir -p /var/lib/alternatives && \
    echo -e "[Daemon]\nAutomaticUpdatePolicy=stage\n" > /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl disable NetworkManager-wait-online.service && \
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
    ln -s /etc/systemd/user/ostree-notify.timer /etc/systemd/user/default.target.wants/ && \
	systemctl enable update-flatpak.timer && \
    ostree container commit
