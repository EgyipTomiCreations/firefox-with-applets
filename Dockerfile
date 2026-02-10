# Base image: Ubuntu latest + XFCE + noVNC
FROM accetto/ubuntu-vnc-xfce:latest

USER root

RUN apt-get update && apt-get install -y \
    wget \
    tar \
    bzip2 \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    openjdk-8-jdk \
    icedtea-8-plugin \
    libgtk-3-dev \
    libdbus-glib-1-dev \
    libxt-dev \
    libglib2.0-dev \
    rustc \
    cargo \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# JDK home variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Download and build NPAPI SDK release tarball
WORKDIR /tmp
RUN wget https://github.com/projg2/npapi-sdk/releases/download/npapi-sdk-0.27.2/npapi-sdk-0.27.2.tar.bz2 -O npapi-sdk.tar.bz2 \
 && tar xjf npapi-sdk.tar.bz2 \
 && mv npapi-sdk-0.27.2 npapi-sdk \
 && cd npapi-sdk \
 && ./configure \
 && make \
 && make install

# IcedTea-Web 1.8 branch clone, autogen and build (BUNDLED)
WORKDIR /tmp
RUN git clone --branch 1.8 https://github.com/AdoptOpenJDK/IcedTea-Web.git icedtea-web \
 && cd icedtea-web \
 && ./autogen.sh \
 && ./configure --with-itw-libs=BUNDLED --with-jdk-home=$JAVA_HOME \
 && make \
 && make install

# Link plugin to Firefox
RUN mkdir -p /usr/lib/mozilla/plugins \
 && ln -s /usr/local/lib/IcedTeaPlugin.so /usr/lib/mozilla/plugins/libnpjp2.so

# Install Firefox ESR 52
WORKDIR /opt
RUN wget https://ftp.mozilla.org/pub/firefox/releases/52.9.0esr/linux-x86_64/en-US/firefox-52.9.0esr.tar.bz2 \
 && tar xjf firefox-52.9.0esr.tar.bz2 \
 && ln -s /opt/firefox/firefox /usr/local/bin/firefox

COPY firefox-gui /usr/local/bin/firefox-gui.sh
RUN chmod +x /usr/local/bin/firefox-gui.sh

COPY Firefox.desktop /home/headless/Desktop/Firefox.desktop
RUN chmod +x /home/headless/Desktop/Firefox.desktop


RUN chmod -R a+rwX /home/headless


WORKDIR ${STARTUPDIR}
ENTRYPOINT ["./vnc_startup.sh"]
