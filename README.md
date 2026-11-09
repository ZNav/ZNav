# Homelab Infrastructure & Hardware Topology

This repository tracks the configuration and NixOS deployment states for the multi-node lab cluster, edge networking routing layers, and local machine configurations.

<img width="4284" height="5712" alt="homelab" src="https://github.com/user-attachments/assets/f42956ac-b474-4537-9996-df0f34a21fc0" />

## Next Steps
  # HTB ez deploy vm partially persistant
  # file manager
  # live TV (playlists with downloaded ads)
  # SSO all services
  # homepage w/ hyperlinks and admin controls
  # remote access (cloudflare tunnel? vpn?)
  # configure router for pihole / other ad blocker
  #
  #mullvad{
  #   find some good form of indexing that allows for playlist creation
  # prowlarr -> qbittorrent -> data
  #}
  # data -> file manager -> jellyfin

## Physical Rack Allocation (12U)

| Unit (U) | Device Identifier | Form Factor | Hardware / Role |
| :---: | :--- | :--- | :--- |
| **1U - 2U** | `PDU` | 1U (0.33U offset) | MT-VIKI 8-Outlet Surge Protector |
| **3U** | `x223` | 1U Vented Shelf | Lenovo ThinkPad X220 (i7 Hacking / HTB Node) |
| **4U** | `t420` | 1U Vented Shelf | Lenovo ThinkPad T420 (i5 Cluster Compute Node) |
| **5U** | — | 1U | Brush Panel / Cable Passthrough |
| **6U** | `gnomenav` | 1U Rackmount | MikroTik RB3011UiA5-RM Core Router |
| **7U** | — | 1U | Brush Panel / Cable Passthrough |
| **8U - 9U** | — | 2U | Open Space |
| **10U** | `x220` / `wifi` | 1U Vented Shelf | Lenovo ThinkPad X220 (i5 Node) + Shared Xfinity XB7 Gateway |
| **11U** | — | 1U | Open Space |
| **12U** | `sasha` | 1U Vented Shelf | MSI Delta 15 (Heavy Compute / GPU Worker Node) |

---

## Node Hardware Specifications

### Edge Routing & Network Security

#### `gnomenav` (Core Router)
* **Hardware:** MikroTik RouterBOARD RB3011UiA5-RM
* **CPU:** Qualcomm Atheros IPQ-8064 Dual-Core @ 1.4 GHz
* **Memory:** 1GB RAM / 128MB NAND Flash
* **OS:** RouterOS
* **Role:** Layer 3 Core Routing, local VLAN management, and LAN backbone interface.

#### `wifi` (Edge Gateway)
* **Hardware:** Technicolor CGM4331COM (Xfinity xFi Advanced Gateway XB7)
* **CPU:** Broadcom BCM3390 Dual-Core @ 1.50GHz
* **Memory:** 1GB DRAM / 2GB Flash
* **Role:** Edge public internet WAN gateway. 

---

### Core Infrastructure & Compute Nodes

#### `x223` (Ultraportable Exploitation / Off-Grid Node)
* **Hardware:** Lenovo ThinkPad X220
* **CPU:** Intel Core i7-2620M (4 threads) @ 2.70GHz
* **RAM:** 8GB DDR3-1333 MHz
* **Storage:** 128GB 2.5" SATA III SSD (RAOYI)
* **Power Modification:** Native motherboard barrel-jack replaced with high-draw USB-C PD interface (Supports up to 140W charging profiles).
* **Power Cell:** 9-Cell extended capacity lithium-ion battery.
* **Role:** Red Team tactical sandbox, dynamic OpenVPN connection targeting HackTheBox environments.

#### `x220` (Cluster Node 01)
* **Hardware:** Lenovo ThinkPad X220
* **CPU:** Intel Core i5-2520M (4 threads) @ 2.50GHz
* **RAM:** 8GB DDR3-1333 MHz
* **Storage:** 1TB 2.5" SATA III SSD (INLAND)
* **Role:** High-capacity persistent fast-storage database and active worker node containerization.

#### `t420` (Cluster Node 02)
* **Hardware:** Lenovo ThinkPad T420
* **CPU:** Intel Core i5-2450M (4 threads) @ 2.50GHz
* **RAM:** 8GB DDR3-1333 MHz
* **Storage:** 500GB 2.5" 7200RPM Mechanical HDD (Hitachi Travelstar HTS72755)
* **Role:** Highly stable secondary failover node handling non-I/O bound calculations and storage logs.

#### `sasha` (Heavy Compute / GPU Worker Node)
* **Hardware:** MSI Delta 15 Gaming Laptop
* **CPU:** AMD Ryzen 7 5800H (8 Cores / 16 Threads) @ 3.20GHz
* **GPU:** AMD Radeon RX 6700M (10GB GDDR6 Dedicated VRAM)
* **RAM:** 16GB DDR4-3200 MHz
* **Storage:** 1TB NVMe PCIe Gen3 M.2 SSD
* **Role:** High-performance processing, compiled source tasks, and heavy service orchestration.

---

### Power & Infrastructure Management
* **Unit Layout:** MT-VIKI 1U Horizontal Rackmount PDU
* **Electrical Parameters:** 125V / 15A Maximum capacity load threshholds (1875W)
* **Circuit Isolation:** Integrated 1200 Joules Surge Protection with physical 15A trip reset toggle.
* **Form Layout:** 90-degree right-angle outlet orientation with isolated 40mm spacious gap sizing to isolate transformer power bricks.
