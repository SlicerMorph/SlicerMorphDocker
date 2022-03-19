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
RUN apt -y install \
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
    openbox-menu \
    python \
    tint2 \
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
 && apt install -f \
 && echo 'tint2 &' >>/etc/xdg/openbox/autostart \
 && apt clean \
 && rm -rf /etc/ld.so.cache \
 && rm -rf /var/cache/ldconfig/* \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* \
 && rm -rf /var/tmp/*

RUN perl -i -p0e 's/  <separator \/>\n  <item label=\"Exit\">\n.*\n  <\/item>\n//s' /etc/xdg/openbox/menu.xml
RUN perl -i -p0e 's/  <item label=\"ObConf\">\n[^\n]*\n  <\/item>\n//s' /etc/xdg/openbox/menu.xml
RUN LNUM=$(sed -n '/launcher_item_app/=' /etc/xdg/tint2/tint2rc | head -1) && \
  sed -i "${LNUM}ilauncher_item_app = /usr/share/applications/slicer.desktop" /etc/xdg/tint2/tint2rc && \
  sed -i "/^launcher_item_app = tint2conf\.desktop$/d" /etc/xdg/tint2/tint2rc

RUN wget -O Slicer.tgz https://app.box.com/shared/static/3ct13tnaravkhzv0q1mm2lvh5s4oe8zr.gz
RUN tar zxf Slicer.tgz -C /tmp
RUN mv /tmp/Slicer /home/docker
RUN rm -fr /tmp/Slicer Slicer.tgz

RUN mkdir -p /home/docker/.config/NA-MIC
COPY ./Slicer.ini /home/docker/.config/NA-MIC/Slicer.ini
COPY /usr/local/shared/backgrounds/Slicer.png /home/docker/Slicer/ 

RUN mkdir /home/docker/.config/tint2
COPY etc/tint2/tint2rc.slicermorph /home/docker/.config/tint2/tintrc
RUN chown -R 1000.1000 /home/docker/.config

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
