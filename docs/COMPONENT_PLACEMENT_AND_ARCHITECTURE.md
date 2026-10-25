# NIDAR AirMouse: Component Placement & System Architecture Guide

**Project:** NIDAR 2026-27 | Track 1 - Drone Innovation | Problem Statement 2 (AirMouse)  
**System:** Autonomous GPS-Denied Search, Mapping & Survivor Localisation Cinewhoop  
**Frame Format:** Custom 3.5" Ducted Unibody Hybrid (Outer Width: 22.1 cm $\le$ 26 cm)

---

## 📸 Annotated 3D Component Placement Diagram

Below is the complete engineering placement figure with labeled callout arrows pointing to the exact location of every component on the drone:

![NIDAR AirMouse Component Placement Architecture](./images/drone_component_placement_diagram.jpg)

---

## 🧭 Multi-Axis Orthographic Stacking & Spatial Coordinates

Every component has been positioned to optimize the center of gravity (CG), isolate sensitive sensors from electromagnetic interference (EMI) and motor vibration, and provide clear lines of sight:

```
========================================================================================
Z-AXIS VERTICAL STACKING PROFILE (ELEVATION VIEW)
========================================================================================

   [+52 mm to +94 mm]   --> 360° 2D Planar LiDAR (LD19 / RPLIDAR C1)
                            - Elevated on 4 structural pylons
                            - 100% unobstructed horizontal laser scan plane above prop ducts
----------------------------------------------------------------------------------------
   [+29 mm to +35 mm]   --> Raspberry Pi AI HAT+ (13 TOPS Hailo-8L Neural Processor)
                            - Stacked on 16mm standoffs above the active cooler
----------------------------------------------------------------------------------------
   [+14 mm to +27 mm]   --> Raspberry Pi 5 Active Cooler (Silver Fins + PWM Blower Fan)
                            - Directly seated on BCM2712 SoC & RP1 I/O Controller
----------------------------------------------------------------------------------------
   [+12 mm to +14 mm]   --> Raspberry Pi 5 Model (4GB RAM) Companion Computer
                            - 58 x 49 mm M2.5 mounting pattern
----------------------------------------------------------------------------------------
   [+4 mm to +9 mm]     --> Matek H743-WLITE Autopilot Flight Controller
                            - Dual ICM-42688-P IMUs, baro, 7 UARTs
                            - Soft-mounted on 4x TPU vibration-isolation grommets (30.5x30.5mm)
========================================================================================
   [0.0 mm to +3.0 mm]  --> BASE CHASSIS DECK (Aerospace Aluminum 7075-T6 / PETG-CF)
                            - Integrated 360° ducted prop guards (93mm ID / 97.4mm OD)
                            - SIMP topology weight-reduction isogrid cutouts (-38.4% mass)
========================================================================================
   [-6.5 mm to -0.5 mm] --> Matek BEC12S-PRO Power Supply Module
                            - Dedicated bottom bay, 9-55V input -> 5.2V @ 5A continuous to Pi 5
                            - 35V 1000µF Low-ESR filter capacitor
----------------------------------------------------------------------------------------
   [-10 mm to -4 mm]    --> MicoAir MTF-01 Optical Flow & Downward ToF Sensor
                            - Recessed belly port facing straight down through floor window
----------------------------------------------------------------------------------------
   [-18 mm to 0.0 mm]   --> 4x Sturdy Landing Skids with Foot Pads
                            - 18mm vertical ground clearance protecting belly sensors & battery
========================================================================================
```

---

## 🗺️ Top-Down Plan View (X-Y Plane Layout)

```
                              [ FRONT / FORWARD NOSE ]
                                         ▲
                                         │
             +---------------------------┴---------------------------+
             |         Raspberry Pi Global Shutter Camera           |
             |       (Tilt-Adjustable Cage: 0° - 20° Downward,       |
             |             120° Wide-Angle Lens Barrel)              |
             +-------------------------------------------------------+
                    /                                         \
                   /                                           \
    +-----------------------------+             +-----------------------------+
    | Front-Left Ducted Shroud    |             | Front-Right Ducted Shroud   |
    | - EMAX ECO II 2004 3000KV   |             | - EMAX ECO II 2004 3000KV   |
    | - Gemfan D90-3 Tri-Blade    |             | - Gemfan D90-3 Tri-Blade    |
    | - 18mm Landing Skid (Below) |             | - 18mm Landing Skid (Below) |
    +-----------------------------+             +-----------------------------+
                   \                                           /
                    \   +---------------------------------+   /
                     ───┤    CENTRAL AVIONICS CORE        ├───
                        | - Top: 360° 2D LiDAR (LD19)     |
                        | - Mid: Pi 5 + Cooler + AI HAT+  |
                        | - Low: Matek H743-WLITE (TPU)   |
                        | - Belly: MicoAir MTF-01 & BEC   |
                     ───┤                                 ├───
                    /   +---------------------------------+   \
                   /                                           \
    +-----------------------------+             +-----------------------------+
    | Rear-Left Ducted Shroud     |             | Rear-Right Ducted Shroud    |
    | - EMAX ECO II 2004 3000KV   |             | - EMAX ECO II 2004 3000KV   |
    | - Gemfan D90-3 Tri-Blade    |             | - Gemfan D90-3 Tri-Blade    |
    | - 18mm Landing Skid (Below) |             | - 18mm Landing Skid (Below) |
    +-----------------------------+             +-----------------------------+
                   \                                           /
                    \                                         /
             +-------------------------------------------------------+
             |      SpeedyBee Nano 2.4G ExpressLRS Receiver          |
             |       + 2.4GHz Dipole T-Antenna on 45° Rear Fin       |
             +-------------------------------------------------------+
                                         │
                              [ REAR / BATTERY PLUG ]
```

---

## 📋 Detailed Component Spatial Matrix

| Item # | Component Name | Spatial Coordinates $(X, Y, Z)$ | Mounting Method | Isolation & Clearance Feature |
| :---: | :--- | :---: | :--- | :--- |
| **1** | **Elevated 360° 2D LiDAR (LD19)** | `(0, 0, +52 mm)` | 4x rigid pylon risers with M2.5 fasteners | Elevated 26mm above prop plane; 0% laser beam clipping |
| **2** | **Raspberry Pi AI HAT+ (13 TOPS)** | `(0, -5 mm, +29 mm)` | 4x M2.5 16mm brass standoffs over Active Cooler | Direct ribbon cable connection to Pi 5 PCIe port |
| **3** | **Raspberry Pi 5 Active Cooler** | `(0, -5 mm, +14 mm)` | Spring-loaded push pins into Pi 5 PCB | Integrated heatsink directly cooling BCM2712 SoC & RP1 |
| **4** | **Raspberry Pi 5 (4GB RAM)** | `(0, 0, +12 mm)` | 58 × 49 mm M2.5 nylon standoffs | Centered over FC; USB/Ethernet ports facing rear-right |
| **5** | **Matek H743-WLITE Autopilot** | `(0, 0, +4 mm)` | 30.5 × 30.5 mm M3 TPU silicone bobbins | Dual IMUs protected against motor vibration frequencies |
| **6** | **Matek BEC12S-PRO (5V/5A)** | `(0, 0, -6.5 mm)` | Dual M2 standoffs in recessed bottom bay | Low-ESR filter capacitor holder; clean 5.2V to Pi 5 |
| **7** | **Pi Global Shutter Camera** | `(0, +68 mm, +8 mm)` | 2x M2 pivot screws in front protective cage | 0° to 20° downward tilt; 120° wide-angle FOV |
| **8** | **MicoAir MTF-01 Optical Flow + ToF** | `(0, 0, -6 mm)` | 4x M2 mounting ears under belly window | Recessed downward view protected by 18mm landing skids |
| **9** | **SpeedyBee Nano ELRS 2.4G RX** | `(0, -62 mm, +4 mm)` | Adhesive TPU sleeve on rear frame extension | T-antenna placed 6cm away from carbon & power cables |
| **10** | **4x EMAX ECO II 2004 3000KV Motors** | `(±62 mm, ±58 mm, +3 mm)`| 12 × 12 mm M2 4-bolt pattern | Rigid aluminum hubs with 3x aerodynamic stator struts |
| **11** | **4x Gemfan D90-3 Tri-Blade Props** | `(±62 mm, ±58 mm, +17 mm)`| 5mm shaft press-fit / T-mount | Spinning inside 93mm ID ducts with 2.0mm tip clearance |
| **12** | **360° Ducted Propeller Guards** | `Outer Width: 22.1 cm` | Monolithic unibody structure | Continuous protective shroud complying with Section 2 |
| **13** | **4x 18mm Landing Skids** | `(±70 mm, ±66 mm, -18 mm)`| Integral structural vertical compression legs | 17mm wide foot pads providing stable touchdown |
| **14** | **Dedicated Wi-Fi 6 Router (GCS)** | Base Station / Ground Node | High-speed 5GHz 802.11ax offline local LAN | Zero-internet GCS streaming for 2D map & camera feed |

---

## 🔌 Interconnect Wiring & Power Distribution Architecture

```
               [ 4S 14.8V-16.8V LiPo Battery (XT60) ]
                                 │
     ┌───────────────────────────┴───────────────────────────┐
     ▼                                                       ▼
[ 4-in-1 35A-45A ESC ]                             [ Matek BEC12S-PRO ]
  │  (Motor Power)                                  (Power Distribution)
  ├── Motor 1 (Front-Right: 2004 3000KV)                     │
  ├── Motor 2 (Front-Left:  2004 3000KV)                     ├──────► 5.2V @ 5A (High Current Line)
  ├── Motor 3 (Rear-Right:  2004 3000KV)                     │        ├── Raspberry Pi 5 USB-C / GPIO
  └── Motor 4 (Rear-Left:   2004 3000KV)                     │        └── Raspberry Pi AI HAT+
                                                             │
                                                             ├──────► 5.0V @ 2A (Avionics Clean Line)
                                                             │        ├── Matek H743-WLITE FC
                                                             │        ├── MicoAir MTF-01 Flow/ToF
                                                             │        └── SpeedyBee Nano ELRS RX
                                                             │
                                                             └──────► 12.0V @ 2A (Peripheral Line)
                                                                      └── 360° 2D LiDAR (LD19 / C1)

DATA & SIGNAL COMMUNICATIONS:
• Matek H743 UART7 (TX/RX) ◄──────────────► Raspberry Pi 5 UART0 (MAVLink Telemetry @ 921600 baud)
• Matek H743 UART4 (MSP)   ◄──────────────► MicoAir MTF-01 Optical Flow + ToF (100 Hz Position/Altitude)
• Matek H743 CRSF UART     ◄──────────────► SpeedyBee Nano ELRS RX (Radio Control & Emergency Kill)
• Raspberry Pi 5 USB 3.0   ◄──────────────► 360° 2D LiDAR LD19 (Cartographer 2D Grid SLAM Point Cloud)
• Raspberry Pi 5 CSI Port  ◄──────────────► Raspberry Pi Global Shutter Camera (High-Speed Video Stream)
• Raspberry Pi 5 PCIe Gen2 ◄──────────────► Raspberry Pi AI HAT+ 13 TOPS (Real-Time YOLOv8 Inference)
• Raspberry Pi 5 Wi-Fi 6   ◄─(Offline LAN)─► Dedicated Wi-Fi 6 Router ◄─► Ground Control Station Screen
```
