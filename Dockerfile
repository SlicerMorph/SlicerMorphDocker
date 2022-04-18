FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu20.04

ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},graphics,compat32,compute,utility

RUN groupadd -g 1000 docker \
 && useradd -u 1000 -g 1000 -m docker -s /bin/bash \
 && usermod -a -G docker docker

RUN apt -y update
RUN apt -y upgrade
RUN ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
RUN apt install -y gnupg
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN apt-get -y install software-properties-common
RUN apt-add-repository universe
RUN apt -y update
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
RUN add-apt-repository ppa:c2d4u.team/c2d4u4.0+
RUN apt -y update
RUN apt-get install -y sudo
RUN apt-get install -y python3 python3-pip
RUN DEBIAN_FRONTEND=noninteractive apt -y install \
    sudo \
    dbus-x11 \
    emacs-nox \
    firefox \
    git \
    libegl1-mesa \
    libegl1-mesa:i386 \
    libglu1-mesa \
    libglu1-mesa:i386 \
    libnss3 \
    libpulse-mainloop-glib0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libxt6 \
    libxt6:i386 \
    libxtst6 \
    libxtst6:i386 \
    libxv1 \
    libxv1:i386 \
    mate-terminal \
    xfce4 \
    python \
    vim-common \
    wget \
    x11-utils \
    x11-xkb-utils \
    x11-xserver-utils \
    xauth \
    ssh-client \
    pcmanfm \
    xarchiver \
    libgomp1 \
    gdebi-core \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    cmake \
    cmake-curses-gui \
    curl \
    pigz \
    vlc \
    ristretto \
 && apt install -f \
 && strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5 \
 && apt clean \
 && rm -rf /etc/ld.so.cache \
 && rm -rf /var/cache/ldconfig/* \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* \
 && rm -rf /var/tmp/*

RUN mkdir -p /home/docker/.config/vlc
COPY ./.config/vlc/vlcrc /home/docker/.config/vlc/vlcrc
RUN chown -R 1000.1000 /home/docker/.config

COPY etc/xdg/xfce4/panel/default.xml /etc/xdg/xfce4/panel/default.xml
RUN chmod 644 /etc/xdg/xfce4/panel/default.xml
RUN rm /etc/xdg/autostart/light-locker.desktop
RUN rm /etc/xdg/autostart/pulseaudio.desktop
RUN rm /usr/share/applications/exo-mail-reader.desktop
RUN rm /usr/share/applications/light-locker-settings.desktop
RUN rm /usr/share/applications/nm-connection-editor.desktop
RUN rm /usr/share/applications/org.freedesktop.IBus.Setup.desktop
RUN rm /usr/share/applications/pavucontrol.desktop
RUN rm /usr/share/applications/xfce4-color-settings.desktop
RUN rm /usr/share/applications/xfce4-notifyd-config.desktop

RUN sed -ie 's@MimeType=\(.*\)image/gif;image/jpeg;image/png;\(.*\)@MimeType=\1\2@g' /usr/share/applications/firefox.desktop
RUN update-mime-database /usr/share/mime
RUN update-desktop-database /usr/share/applications

COPY usr/local /usr/local
RUN chmod 755 /usr/local \
 && chmod 755 /usr/local/shared \
 && chmod 755 /usr/local/shared/backgrounds \
 && chmod 644 /usr/local/shared/backgrounds/*
COPY usr/share/applications /usr/share/applications
RUN chmod 755 /usr/share/applications \
 && chmod 644 /usr/share/applications/*


USER docker
WORKDIR /home/docker
