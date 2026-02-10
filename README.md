# Firefox with Java Applet Support (Legacy Container)

⚠️ **Disclaimer**
Java applets are deprecated and widely unsupported by modern web browsers due to significant security risks and lack of active development.
This container is provided **as-is** for the sole purpose of running **legacy applications** that require Java applet support within a **controlled environment**.
**Use at your own risk.**  
Do **not** expose this container to untrusted networks or sensitive data.

---

## Image

Prebuilt image available on [**Docker Hub**](https://hub.docker.com/r/egyiptomi/firefox-with-applets).  

```
egyiptomi/firefox-with-applets:latest
```

---

## Running the Container

### Using Docker

```bash
docker pull egyiptomi/firefox-with-applets:latest

docker run -d \
  --name firefox-with-applets \
  --restart always \
  -p 5900:5900 \
  -p 6080:6080 \
  --shm-size=2g \
  egyiptomi/firefox-with-applets:latest
```

---

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
services:
  desktop:
    image: egyiptomi/firefox-with-applets:latest
    container_name: firefox-with-applets
    restart: always

    ports:
      - "5900:5900"  # VNC
      - "6080:6080"  # noVNC web

    shm_size: "2gb"
```

Start the container:

```bash
docker compose up -d
```

Stop the container:

```bash
docker compose down
```

---

## Accessing the Container

| Method | Address |
|-------|---------|
| **VNC** | `localhost:5900` |
| **noVNC (Web)** | `http://localhost:6080` |

---
## Overview

This project provides a Docker container designed to run **legacy web applications** that rely on **Java applets**.

It bundles:

- **Firefox ESR 52**
- **IcedTea-Web (NPAPI plugin)**
- A **VNC-enabled Linux desktop**

This combination allows NPAPI-based Java applets to run in a sandboxed environment.

---

## Base Image

Built on top of:

- **dcsunset/ubuntu-vnc:18.04**  

This base image provides:

- XFCE desktop environment
- VNC server
- noVNC web access

---

## Included Software & Build Details

### 1. NPAPI SDK

- Source: https://github.com/projg2/npapi-sdk  
- Provides headers and tooling required for NPAPI plugin support.

### 2. IcedTea-Web (1.8)

- Built **from source**
- Source: https://github.com/AdoptOpenJDK/IcedTea-Web/tree/1.8
- Provides:
  - Java Web Start
  - Java NPAPI browser plugin (`Icedteaplugin.so`)

### 3. Mozilla Plugin Integration

- `Icedteaplugin.so` is linked into Firefox’s plugin directory
- Enables Java applet execution inside Firefox

### 4. Firefox ESR 52

- Last Firefox ESR version with **NPAPI support**
- Required for Java applets to function

---


