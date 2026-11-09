<img width="4284" height="5712" alt="homelab" src="https://github.com/user-attachments/assets/f42956ac-b474-4537-9996-df0f34a21fc0" />

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
