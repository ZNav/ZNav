# Homelab Infrastructure & Hardware Topology

This repository tracks the configuration and NixOS deployment states for the multi-node lab cluster, edge networking routing layers, and local machine configurations.

<img width="4284" height="5712" alt="homelab" src="https://github.com/user-attachments/assets/f42956ac-b474-4537-9996-df0f34a21fc0" />

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


specs:
homelab = {
#this is my homelab, it runs the following devices with each having their respective configuration.nix containing their services 

#1-2u
  PDU = {
1u - mounted 0.33u lower than 1u (which means 1u AND 2u are not mountable) to allow for power cords to passthru over top
    MT-VIKI Rackmount PDU
    8 Outlet
    125V/15A, 1200J
  };
  
#3u
  x223 = {
1u - vented shelf
    Lenovo Thinkpad X220
    Intel Core i7-2620M CPU @ 2.70GHz
    8GB DDR3-1333
    128GB 2.5" SATA III SSD (RAOYI)
    9-Cell Battery
    USB-C PD replacing barrel-jack from motherboard (Supports up to 140W charging)
  };
  
#4u
  t420 = {
1u - vented shelf
    Lenovo Thinkpad T420
    Intel Core i5-2450M CPU @ 2.50GHz
    8GB DDR-1333
    500GB 2.5" 7200RPM HDD (Hitachi Travelstar HTS72755)
  };
  
#5u
1u - cable passthru / organizer

#6u
  gnomenav = {
1u
    MikroTik router board RB3011UiA5-RM
    Qualcomm Atheros IPQ-8064 @ 1.4 GHz
    1GB RAM
    128MB NAND
    RouterOS
  };
  
#7u
1u - cable passthru / organizer

#8u

#9u

#10u
    wifi = {
  0u - sharing x220 vented shelf
    Technicolor CGM4331COM
    Broadcom BCM3390 Dual-Core @ 1.50GHz
    1GB DRAM / 2GB Flash
  };
  
  x220 = {
1u - vented shelf
    Lenovo Thinkpad X220
    Intel Core i5-2520M CPU @ 2.50GHz
    8GB DDR3-1333
    1TB 2.5" SATA III SSD (INLAND)
  };
  
#11u

#12u
  sasha = {
1u - vented shelf
    MSI 15 Delta
    AMD Ryzen 7 5800H
    AMD Radeon RX 6700M with 10GB GDDR6 dedicated VRAM
    16GB DDR4-3200
    1TB NVMe PCIe Gen3 M.2 SSD
  };
  
};
