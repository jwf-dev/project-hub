---
title: "Traefik Setup"
description: "Setting up TrueCharts with Traefik on TrueNAS."
icon: "traefikproxy"
lastmod: "2024-05-11T00:40:04-07:00"
draft: false
categories:
  - Bits
tags:
  - TrueNAS
  - TrueCharts
  - Traefik
---

## Overview

Setup Traefik, with TrueCharts, and configure ingress on TrueNAS Scale.

### Assumptions

-   [TrueNAS Scale setup](/bits/truenas/scale-setup/) completed.

-   [TrueCharts catalog setup](/bits/truenas/truecharts-setup/)
    completed.

-   [Certificate setup](/bits/truenas/certificate-setup/) completed.

-   Logged in as administrative user.

## Entrypoint

Traefik will be the primary entrypoint for application traffic to the
server. Prepare the server before installing Traefik depending on the
load balancer employed on the system: integrated or MetalLB.

### Integrated Load Balancer

If using the integrated load balancer, the Traefik application will
likely share an IP address with the TrueNAS server. The TrueNAS
dashboard is running on port 80 and 443 by default. Change the ports
TrueNAS binds to so Traefik can utilize port 80 and 443, for a seamless
HTTP and HTTPS experience.

Navigate to `System Settings` - `General` and open the settings for
`GUI`.

Modify the web interface configuration as required. Choose new port
numbers for the web interface.

| Setting                  | Value   | Description           |
|--------------------------|---------|-----------------------|
| Web Interface HTTP Port  | `13080` | Choose an HTTP port.  |
| Web Interface HTTPS Port | `13443` | Choose an HTTPS port. |

Save the configuration and begin the confirmation process. The changes
must be manually confirmed by accessing the server from the newly
configured port.

Using the system IP address or configured domain, connect to TrueNAS
using the configured port.

```bash
https://172.16.13.13:13443/
https://truenas.example.com:13443/
```

Once port 80 and 443 have been released from TrueNAS, continue to
installing Traefik.

### MetalLB

If setup and using MetalLB, Traefik should be configured to have a
different IP address on the load balancer. Pick an IP address to use on
the network and use it in the `LoadBalancer IP` configuration for the
web entrypoints in Traefik. With this configuration, both TrueNAS and
Traefik can use ports 80 and 443 on their own IP address. For example,
`192.168.1.44` will be used.

## Install Traefik

Navigate to the `Applications` page in the TrueNAS Scale dashboard,
`Apps` on the main navigation.

Switch to the `Available Applications` tab in the `Applications` page.

Using the search tool, find the `traefik` application. Verify Traefik is
from the `TrueCharts` catalog and is on the `Enterprise` train.

Select `Install` to begin configuration and installation of the
application. Configuration options not mentioned in this section can be
left as default.

### Application Name

| Setting          | Value     | Description                        |
|------------------|-----------|------------------------------------|
| Application Name | `traefik` | Name for the application.          |
| Version Number   | `#.#.#`   | Version to use, latest by default. |

### App Configuration

| Setting            | Value               | Description                     |
|--------------------|---------------------|---------------------------------|
| Expert Mode        | `false`             | Enable if needed.               |
| Log Level          | `Errors`            | How detailed logging should be. |
| General Log Format | `Common Log Format` | Format for creating logs.       |
| Access Logs        | `false`             | Enable to use access logging.   |

### Networking and Services

| Setting | Value | Description |
|----|----|----|
| Main Service | — | — |
| Service Type | `ClusterIP (Do Not Expose Ports)` | Traefik service dashboard, use `ClusterIP` so it can be accessed via ingress. |
| Port | `9000` | Default port. |
| TCP Service | — | — |
| Service Type | `Load Balancer (Expose Ports)` | TCP web entrypoint service for Traefik. |
| LoadBalancer IP | `192.168.1.44` | Only use with MetalLB, use a chosen IP address for the Traefik application to be exposed on. Leave blank if using integrated load balancer. |
| Web Entrypoint Port | `80` | HTTP port. |
| Web Secure Entrypoint Port | `443` | HTTPS port. |

### Storage and Persistence

| Setting | Value | Description |
|----|----|----|
| App Config Storage | — | — |
| Type of Storage | `PVC` | Use PersistentVolume. |
| Read Only | `false` | Keep disabled, write permission required. |
| Size quotum of Storage | `16Gi` | Maximum disk usage - can never be decreased, only increased. |

### Ingress

This ingress configuration only relates to the administrative dashboard
of Traefik. Enable ingress to access the Traefik dashboard, but note
that it will lack any login protection until an authentication provider
is setup.

| Setting | Value | Description |
|----|----|----|
| Main Ingress | — | — |
| Enable Ingress | `true` | Toggle ingress state. |
| HostName | `traefik.example.com` | Ingress host on the server domain. |
| Path | `/` | Root path. |
| Path Type | `Prefix` | Prefix path. |
| Cert-Manager clusterIssuer | `cert` | Cluster issuer for automatic certificates. |
| Traefik Middlewares |  | Leave empty until authentication provider is setup. |

Once an authentication provider has been setup, configure the middleware
for the ingress.

### Save

Verify you have checked the TrueCharts documentation for Traefik and
`Save`. The application will begin installation and deploy. Navigate to
the `Installed Applications` tab to monitor the status.

## Traefik Dashboard

When Traefik enters the `ACTIVE` state, navigate to the dashboard in a
browser window.

```bash
https://traefik.example.com/dashboard/
```

<img src="./traefik-dashboard.png" class="img-fluid"
alt="Traefik network dashboard." />

## References

<sup><a href="#fn:1" class="footnote-ref" role="doc-noteref">1</a></sup>
<sup><a href="#fn:2" class="footnote-ref" role="doc-noteref">2</a></sup>
<sup><a href="#fn:3" class="footnote-ref" role="doc-noteref">3</a></sup>

------------------------------------------------------------------------

1.  <a href="https://www.truenas.com/docs/scale/" target="_blank"
    rel="noopener noreferrer">TrueNAS Scale Documentation</a> <a href="#fnref:1" class="footnote-backref" role="doc-backlink">↩︎</a>

2.  <a href="https://truecharts.org/manual/intro" target="_blank"
    rel="noopener noreferrer">TrueCharts Documentation</a> <a href="#fnref:2" class="footnote-backref" role="doc-backlink">↩︎</a>

3.  <a href="https://doc.traefik.io/traefik/" target="_blank"
    rel="noopener noreferrer">Traefik Documentation</a> <a href="#fnref:3" class="footnote-backref" role="doc-backlink">↩︎</a>

-   <a href="/sitemap.xml" class="nav-link px-2">Sitemap</a>
-   <a href="/credits/" class="nav-link px-2" title="Credits">Credits</a>
-   <a href="/privacy/" class="nav-link px-2" title="Privacy">Privacy</a>
-   <a href="/disclaimer/" class="nav-link px-2"
    title="Disclaimer">Disclaimer</a>
