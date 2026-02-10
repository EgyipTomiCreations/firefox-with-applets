# Firefox with Java Applet Support (Legacy Container)

**Disclaimer:** Java applets are deprecated and widely unsupported by modern web browsers due to significant security risks and lack of active development. This container is provided *as-is* for the sole purpose of running legacy applications that require Java applet support within a controlled environment. **Use at your own risk.** It is highly recommended to only use this container for isolated, non-sensitive tasks and to not expose it to untrusted networks.

## Overview

This project provides a Docker container designed to run older web applications that rely on Java applets. It bundles a specific version of Firefox (ESR 52) with IcedTea-Web to enable NPAPI Java plugin functionality.

## Base Image

The container is built upon the following base image, providing a VNC-enabled Ubuntu desktop environment:

*   [accetto/ubuntu-vnc-xfce](https://github.com/accetto/ubuntu-vnc-xfce)

## Included Software and Build Process

The following components are installed and configured within the container:

1.  **NPAPI SDK**:
    The [NPAPI SDK](https://github.com/projg2/npapi-sdk) is installed to provide the necessary headers and tools for building NPAPI plugins.

2.  **IcedTea-Web**:
    The [IcedTea-Web (version 1.8)](https://github.com/AdoptOpenJDK/IcedTea-Web/tree/1.8) project is built from source. IcedTea-Web provides a free software implementation of Java Web Start and the Java browser plugin, which includes `Icedteaplugin.so`.

3.  **Mozilla Plugin Linking**:
    The compiled `Icedteaplugin.so` dynamic library is linked into the Mozilla Firefox plugin directory to enable Java applet support within the browser.

4.  **Firefox ESR 52**:
    A specific version of Firefox, ESR 52 (Extended Support Release), is installed. This version is chosen for its compatibility with NPAPI plugins, which are no longer supported in modern Firefox releases.

## Accessing the Container

The container can be accessed via VNC and noVNC:

*   **VNC**: Connect to the container using a VNC client.
*   **noVNC**: Access through your web browser via noVNC.

The default VNC password for the container is `headless`.
