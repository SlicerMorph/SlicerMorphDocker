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
    r-base \
    r-base-core \
    r-recommended \
    r-base-dev \
    r-cran-rgl \
    pigz \
 && wget https://s3.amazonaws.com/virtualgl-pr/main/linux/virtualgl_2.6.91_amd64.deb \
 && dpkg -i virtualgl*.deb \
 && wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.4.1717-amd64.deb \
 && gdebi --non-interactive rstu*.deb \
 && rm *.deb \
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
  sed -i "${LNUM}ilauncher_item_app = /usr/share/applications/slicer-vgl.desktop" /etc/xdg/tint2/tint2rc && \
  sed -i "${LNUM}ilauncher_item_app = /usr/share/applications/slicer.desktop" /etc/xdg/tint2/tint2rc && \
  sed -i "/^launcher_item_app = tint2conf\.desktop$/d" /etc/xdg/tint2/tint2rc

RUN mkdir -p /home/docker/.config/NA-MIC
COPY ./Slicer.ini /home/docker/.config/NA-MIC/Slicer.ini

RUN mkdir /home/docker/.config/tint2
COPY tint2rc /home/docker/.config/tint2
RUN chown -R 1000.1000 /home/docker/.config

COPY usr/local /usr/local
RUN chmod 755 /usr/local \
 && chmod 755 /usr/local/shared \
 && chmod 755 /usr/local/shared/backgrounds \
 && chmod 644 /usr/local/shared/backgrounds/*
COPY usr/share/applications /usr/share/applications
RUN chmod 755 /usr/share/applications \
 && chmod 644 /usr/share/applications/*

ENV RETICULATE_MINICONDA_PATH="/home/docker/MyData/r-miniconda/"
RUN mkdir /home/docker/.conda
RUN echo -e "/home/docker/MyData/r-miniconda \n /home/docker/MyData/r-miniconda/envs/r-reticulate" > /home/docker/.conda/environments.txt

COPY .Rprofile /home/docker/
RUN chown -R 1000.1000 /home/docker/.Rprofile
USER docker
WORKDIR /home/docker
