############################
# 1. BUILDER STAGE
############################
FROM ubuntu:18.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    tar \
    bzip2 \
    git \
    zip \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    openjdk-8-jdk \
    libgtk-3-dev \
    libdbus-glib-1-dev \
    libxt-dev \
    libglib2.0-dev \
    rustc \
    cargo \
 && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# ---- NPAPI SDK ----
WORKDIR /tmp
RUN wget https://github.com/projg2/npapi-sdk/releases/download/npapi-sdk-0.27.2/npapi-sdk-0.27.2.tar.bz2 \
 && tar xjf npapi-sdk-0.27.2.tar.bz2 \
 && cd npapi-sdk-0.27.2 \
 && ./configure \
 && make \
 && make install

# ---- IcedTea-Web ----
WORKDIR /tmp
RUN git clone --branch 1.8 https://github.com/AdoptOpenJDK/IcedTea-Web.git \
 && cd IcedTea-Web \
 && ./autogen.sh \
 && ./configure --with-itw-libs=BUNDLED --with-jdk-home=$JAVA_HOME \
 && make \
 && make install

 ############################
# 2. RUNTIME STAGE
############################
FROM dcsunset/ubuntu-vnc:18.04

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Csak runtime függőségek
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    bzip2 \
    openjdk-8-jre \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    libxt6 \
    libglib2.0-0 \
    fontconfig \
    libnss3 \
    libxrender1 \
    libxtst6 \
 && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# --- runtime stage ---
# Copy everything installed by IcedTea-Web builder
COPY --from=builder /usr/local/lib/IcedTeaPlugin.so /usr/local/lib/IcedTeaPlugin.so
COPY --from=builder /usr/local/share/icedtea-web /usr/local/share/icedtea-web
COPY --from=builder /usr/local/bin/javaws /usr/local/bin/javaws
COPY --from=builder /usr/local/bin/itweb-settings /usr/local/bin/itweb-settings
COPY --from=builder /usr/local/bin/policyeditor /usr/local/bin/policyeditor
COPY --from=builder /usr/local/bin/itw-modularjdk.args /usr/local/bin/itw-modularjdk.args
COPY --from=builder /usr/local/share/pixmaps/javaws*.png /usr/local/share/pixmaps/
COPY --from=builder /usr/local/etc/bash_completion.d /usr/local/etc/bash_completion.d
COPY --from=builder /usr/local/share/man /usr/local/share/man
COPY --from=builder /usr/local/share/doc/icedtea-web /usr/local/share/doc/icedtea-web

RUN mkdir -p /usr/lib/mozilla/plugins \
 && ln -s /usr/local/lib/IcedTeaPlugin.so /usr/lib/mozilla/plugins/libnpjp2.so

# ---- Firefox ESR 52 ----
WORKDIR /opt
RUN wget https://ftp.mozilla.org/pub/firefox/releases/52.9.0esr/linux-x86_64/en-US/firefox-52.9.0esr.tar.bz2 \
 && tar xjf firefox-52.9.0esr.tar.bz2 \
 && ln -s /opt/firefox/firefox /usr/local/bin/firefox \
 && rm -rf firefox-52.9.0esr.tar.bz2

# ---- Delete the updater ----

RUN rm -f /opt/firefox/updater \
    /opt/firefox/update-settings.ini \
    /opt/firefox/updater.ini

RUN useradd -ms /bin/bash headless
WORKDIR /home/headless

# ---- Firefox disable update ----
COPY disable-update.js /home/headless/.mozilla/firefox/prefs.js

# ---- Java security policy ----
COPY java.policy /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.policy

# ---- GUI launcher ----
COPY firefox-gui /usr/local/bin/firefox-gui.sh
RUN chmod +x /usr/local/bin/firefox-gui.sh

COPY Firefox.desktop /home/headless/Desktop/Firefox.desktop
RUN chmod +x /home/headless/Desktop/Firefox.desktop

RUN chmod -R a+rwX /home/headless



USER headless