# NIDAR AirMouse: Airframe Rulebook Analysis, CAD Architecture & Propulsion Engineering

**Project:** NIDAR 2026-27 | Track 1 - Drone Innovation | Problem Statement 2 (AirMouse)  
**Challenge:** Autonomous GPS-Denied Indoor Search, Mapping & Survivor Localisation  
**Author / Team:** Navaneeth (`Navaneeth2926`)

---

## 1. Rulebook Verification & Legal Assessment

### 1.1 Commercial Airframe Legality
**Verdict: Commercial complete drone airframes and ready-to-fly (RTF/BNF) kits are STRICTLY PROHIBITED.**

### 1.2 Exact Verbatim Quotes from Official Competition Documentation

#### A. General Technical & Operational Requirements (Rulebook Section 8, Rule 8.2, Page 16)
> *"8.2. The use of commercially available, market-ready or ready-to-fly complete drone airframes shall not be permitted. Teams may use commercially available components, open-source software and custom-developed hardware or software, unless otherwise specified in the relevant Problem Statement Annexure."*

#### B. Engineering Autonomy Requirement (Rulebook Section 8, Rule 8.1, Page 16)
> *"8.1. Teams shall independently design, develop, integrate and demonstrate their complete solutions."*

#### C. AirMouse Specific Drone Constraints (Rulebook Section 2, Page 35 & Mission Brief Page 2)
> *"● Use of commercially available market-ready or ready-to-fly complete drone airframes shall not be permitted."*  
> *"● The combined all-up weight of the deployed drone, including batteries, onboard systems, sensors, communication equipment, payload mechanisms, and any other component, must not exceed 10 kg."*  
> *"● The drone must be equipped with propeller covers or guards that fully protect the propeller operating area."*

#### D. Launch Box & Arena Geometry Constraints (Rulebook Section 9, Page 37 & Mission Brief Page 4)
> *"● The drone must be launched from within a fixed 2 feet x 2 feet launch area."*  
> *"● No part of the drone shall cross or remain outside the designated launch area before mission start."*  
> *"● The drone must be sized and configured to operate safely within corridors having a minimum clear width of 1 metre and a minimum vertical clearance of 8 feet."*

### 1.3 Permitted vs. Prohibited Summary
| Category | Status | Details / Reference |
| :--- | :--- | :--- |
| **Commercial Complete Airframe / RTF Drone** | ❌ **BANNED** | Any pre-built frame kit (e.g. GEPRC CineLog35 frame, BetaFPV Pavo35, iFlight Protek35) will cause disqualification during technical scrutineering. |
| **Commercial Off-the-Shelf Components** | ✅ **ALLOWED** | Flight controllers, companion computers, LiDAR, sensors, motors, ESCs, props, BECs, batteries (Rule 8.2). |
| **Custom 3D-Printed / Fabricated Airframe** | ✅ **MANDATORY** | Custom-designed unibody frame (PETG-CF / SIMP optimized) with integrated 360° prop guards meets 100% of competition rules. |

---

## 2. Airframe Design Architecture & Fusion 360 Integration

### 2.1 Dimensional Compliance
- **Corridor Width:** 1000 mm (1.0 m)
- **Launch Box Limit:** 2 ft × 2 ft = 609.6 mm × 609.6 mm
- **Designed Airframe Dimensions:**
  - **Outer Width:** **236 mm (23.6 cm)** (Meets the target $\le 26.0\text{ cm}$ specification; leaves $>38\text{ cm}$ lateral buffer in 1m corridors)
  - **Outer Length:** **242 mm (24.2 cm)**
  - **Total Height:** **62 mm** (including elevated LiDAR tower and bottom landing skids)
  - **Motor-to-Motor Diagonal (Wheelbase):** **158 mm** (Squished-X Deadcat layout)

### 2.2 Component Stacking & Integration Scheme
```
                       +-----------------------------------+
                       |    360° 2D Planar LiDAR (LD19)    |  <-- Elevated Tower (Clear 360° scan)
                       +-----------------------------------+
                                         | (M2.5 Standoffs)
                       +-----------------------------------+
                       | Raspberry Pi AI HAT+ (13 TOPS)    |
                       +-----------------------------------+
                       | Raspberry Pi 5 Active Cooler      |
                       +-----------------------------------+
                       | Raspberry Pi 5 (4GB RAM)          |  <-- 58 x 49 mm mounting
                       +-----------------------------------+
                                         |
+---------------------+ +-----------------------------------+ +---------------------+
| Raspberry Pi Global | | Matek H743-WLITE Autopilot (FC)   | | 4S LiPo Battery Bay |
| Shutter Camera Cage | | (30.5x30.5mm TPU Vibration Mount) | | (Dual 20mm Straps)  |
+---------------------+ +-----------------------------------+ +---------------------+
                                         |
                        +-----------------------------------+
                        | 4-in-1 ESC + Matek BEC12S-PRO     |
                        | + 35V 1000µF Low-ESR Filter Cap   |
                        +-----------------------------------+
                                         |
                        +-----------------------------------+
                        | MicoAir MTF-01 Optical Flow + ToF |  <-- Bottom Belly Cutout
                        +-----------------------------------+
                                    |         |
                              [TPU Landing Skids (15mm)]
```

### 2.3 Autodesk Fusion 360 Automation
The included script [`cad/generate_nidar_airmouse_frame.py`](../cad/generate_nidar_airmouse_frame.py) connects directly to the Autodesk Fusion 360 B-Rep Modeling API to create:
1. Parametric center fuselage deck with standard mounting patterns (30.5×30.5 mm M3, 20×20 mm M2.5, 58×49 mm Pi 5).
2. Four continuous 360° ducted prop guards with 93 mm internal diameter (for 3.5" props with 2.05 mm blade clearance) and aerodynamic bellmouth inlet flare.
3. 3-strut stator arm bridges with teardrop aerodynamic cross-sections to eliminate thrust loss.
4. Integrated front camera protection cage and elevated top LiDAR mounting tower.

Alternatively, the OpenSCAD script [`cad/nidar_airmouse_frame.scad`](../cad/nidar_airmouse_frame.scad) compiles directly to STL/3MF for instant slicing.

### 2.4 3D Printing & Material Specifications
* **Main Unibody Frame:** **PETG-CF** (Carbon-Fiber Reinforced Polyethylene Terephthalate Glycol)
  * *Why:* Extremely rigid, zero warping (unlike Nylon-CF), high impact absorption when bumping into maze walls, UV/heat stable up to 80°C.
  * *Nozzle:* 0.4 mm or 0.6 mm Hardened Steel (245°C - 260°C).
  * *Bed:* 75°C - 85°C (Textured PEI).
  * *Perimeters / Walls:* 4 to 5 perimeters (1.6 - 2.0 mm solid wall thickness).
  * *Infill:* 35% Gyroid or Honeycomb.
* **Vibration Dampers & Bumpers:** **TPU 95A**
  * Flight controller mounting grommets (soft isolation against motor vibrations).
  * Bottom landing feet (absorbs hard touchdowns and protects downward optical flow sensor).

---

## 3. Propulsion System Physics: Motors, Blades & Power

### 3.1 Drone All-Up-Weight (AUW) Breakdown
| Component | Quantity | Unit Mass (g) | Subtotal Mass (g) |
| :--- | :---: | :---: | :---: |
| Custom 3.5" PETG-CF Unibody Frame + Hardware | 1 | 145.0 | 145.0 |
| Raspberry Pi 5 (4GB) | 1 | 46.0 | 46.0 |
| Raspberry Pi AI HAT+ (13 TOPS Hailo-8L) | 1 | 14.5 | 14.5 |
| Raspberry Pi 5 Active Cooler | 1 | 24.5 | 24.5 |
| Raspberry Pi Global Shutter Camera + Lens | 1 | 28.0 | 28.0 |
| Matek H743-WLITE Flight Controller | 1 | 25.0 | 25.0 |
| 4-in-1 35A-45A BLHeli_32 / AM32 ESC | 1 | 22.0 | 22.0 |
| Matek BEC12S-PRO + Low-ESR Filter Cap + Wiring | 1 | 21.0 | 21.0 |
| 360° 2D Planar LiDAR (LD19 / D300) | 1 | 42.0 | 42.0 |
| MicoAir MTF-01 (Optical Flow + ToF) | 1 | 4.5 | 4.5 |
| SpeedyBee Nano 2.4G ExpressLRS Receiver | 1 | 1.8 | 1.8 |
| Brushless Motors (2004 / 3000KV) | 4 | 16.4 | 65.6 |
| Gemfan D90-3 3.5" Tri-Blade Propellers | 4 | 2.5 | 10.0 |
| 4S 1500mAh 100C LiPo Battery (or 4S 18650 Pack) | 1 | 185.0 | 185.0 |
| **Total All-Up Weight (AUW)** | — | — | **~634.9 g** |

*Note: With cable harnesses, zip ties, and TPU mounts, target operational AUW is **~680 g - 720 g**.*

---

### 3.2 Why Smaller Drones Require Higher Motor RPM (Physics Derivation)

Aerodynamic thrust generated by an open/ducted rotor is governed by:
$$T = C_T \cdot \rho \cdot A \cdot (\Omega \cdot R)^2 = C_T' \cdot \rho \cdot D^4 \cdot n^2$$

Where:
* $D$ = Propeller diameter
* $n$ = Rotational speed (revolutions per second / RPM)
* $\rho$ = Air density ($1.225\text{ kg/m}^3$)
* $C_T$ = Thrust coefficient

#### The Impact of Downsizing to 3.5"
Comparing a standard 5" drone propeller to our 3.5" ducted propeller:
$$\left(\frac{D_{3.5}}{D_{5.0}}\right)^4 = \left(\frac{3.5}{5.0}\right)^4 = (0.7)^4 \approx 0.2401$$

> **Key Takeaway:** A 3.5" propeller has **less than 25% of the thrust-generating factor ($D^4$)** of a 5" propeller at the same RPM!

To lift the 700g payload, the deficit must be compensated by **increasing the rotational speed $n$**:
$$n_{3.5} \approx \sqrt{\frac{1}{0.2401}} \cdot n_{5.0} \approx 2.04 \times n_{5.0}$$

Therefore, on a 4S battery supply ($14.8\text{V} - 16.8\text{V}$):
* A low KV motor (e.g., 1800-2100KV) would spin at $\approx 28,000\text{ RPM}$, leaving the drone dangerously sluggish with hover throttle $>65\%$.
* A **2700KV - 3000KV motor** spins at:
  $$\text{RPM}_{\text{unloaded}} = 3000\text{ KV} \times 16.8\text{ V} = 50,400\text{ RPM}$$
  $$\text{RPM}_{\text{loaded}} \approx 34,000 - 38,000\text{ RPM}$$
* At this RPM, each 3.5" prop produces **~520 g of thrust**, yielding a total thrust of **~2,080 g**.
* **Thrust-to-Weight Ratio:** $\frac{2080\text{ g}}{680\text{ g}} \approx 3.06 : 1$.
* This provides a **35-40% hover throttle point**, giving the autonomous flight controller instant dynamic authority to counter air drafts and execute rapid cornering in 1-meter corridors!

---

### 3.3 Propeller Selection: Twin-Blade (2-Blade) vs. Tri-Blade (3-Blade)

| Parameter | Twin-Blade (2-Blade) | Tri-Blade (3-Blade) | Winner for NIDAR AirMouse |
| :--- | :--- | :--- | :--- |
| **Thrust per Disc Area** | Lower disc solidity; lower static thrust. | **+20% to +25% higher static thrust** in the same 3.5" diameter. | **Tri-Blade (Decisive)** |
| **Hover Efficiency** | Slightly higher open-air cruise efficiency. | **Higher low-speed static thrust**; ideal for confined indoor hover. | **Tri-Blade** |
| **Duct Wall Coupling** | Large pressure gaps between passes; pulsation. | Continuous aerodynamic pressure along duct wall (shroud lift). | **Tri-Blade** |
| **Vibration & IMU Noise** | Higher 2nd-order torque ripple; more gyro noise. | **Smoother torque delivery**; lower vibration amplitude for MTF-01 & FC. | **Tri-Blade** |
| **Braking / Deceleration** | Slower dynamic braking inside corridors. | **High aerodynamic drag on throttle drop**; snappy deceleration. | **Tri-Blade** |

**Conclusion:** **Tri-Blade (3-Blade) propellers are mandatory** for ducted cinewhoop indoor autonomous operations.

#### Recommended Propeller Models
1. **Gemfan D90-3 (or D90S-3):**
   * *Diameter:* 90 mm (3.54 in) | *Pitch:* 3.0 in | *Blades:* 3 | *Mounting:* 1.5 mm T-mount / 5 mm center hole.
   * Specially designed for ducted cinewhoops with flared tip geometry for minimum tip clearance loss.
2. **HQProp DP-D90MMX3:**
   * *Diameter:* 90 mm | *Pitch:* 3.0 in | *Blades:* 3 | *Material:* Polycarbonate (crash-resistant).
3. **Gemfan 3520-3:**
   * *Diameter:* 3.5 in | *Pitch:* 2.0 in | *Blades:* 3 | Lower pitch for ultra-smooth hover and lowest battery consumption.

---

### 3.4 Motor Sourcing & Market Evaluation (India)
* **Budget Constraint:** Total for 4 motors must be **₹5,000 to ₹7,000 max**.
* **Delivery Window:** **Within 2 weeks** (must ship domestically from Indian distributors).

#### Comparative Market Matrix
| Motor Model | KV Rating | Mount Pattern | Weight | Thrust (4S / 3.5" Prop) | Price / Unit (INR) | Total for 4 Motors | Indian Retailer & Delivery Time |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **1. EMAX ECO II 2004** *(Recommended)* | **3000KV** | 12×12 mm M2 | 16.4 g | 520 g @ 17.5A | **₹1,739** | **₹6,956** | **Robu.in** (2-4 business days express delivery from Pune) |
| **2. T-Motor F2004** | **3000KV** | 12×12 mm M2 | 16.4 g | 510 g @ 16.8A | **₹1,699** | **₹6,796** | **Robu.in / QuadKopter.in** (3-5 business days) |
| **3. HGLRC Aeolus 2004** | **3000KV** | 12×12 mm M2 | 16.6 g | 495 g @ 16.2A | **₹1,499** | **₹5,996** | **Robu.in / Drkarts** (3-5 business days) |
| **4. FLYCCI FK2004 V2** | **3150KV** | 12×12 mm M2 | 16.2 g | 535 g @ 18.2A | **₹1,350** | **₹5,400** | **Electropi / QuadKopter.in** (3-5 business days) |

#### Sourcing Recommendation
* **Primary Choice:** **EMAX ECO II 2004 3000KV** (₹6,956 total on Robu.in)
  * Fits the exact ₹7,000 ceiling.
  * Features N52SH arc magnets and Japanese NSK precision bearings, which offer the lowest electrical EMF noise—vital when running the sensitive Matek H743 magnetometer and Raspberry Pi AI HAT+ nearby.
* **Budget Alternative:** **HGLRC Aeolus 2004 3000KV** (₹5,996 total) leaves ₹1,000 headroom in the motor budget for spare Gemfan D90 props.

---

## 4. Electrical Power Wiring & Filter Capacitor Architecture

```
[4S 14.8V-16.8V LiPo] 
        |
    [XT60 Plug]
        |
        +=======================================================+
        |                                                       |
 [Rubycon 35V 1000µF Low-ESR]                            [Matek BEC12S-PRO]
        |                                                       |
 [4-in-1 35A-45A ESC]                                    +------+------+
        |                                                |             |
 [4x 2004 3000KV Motors]                           5.2V @ 5A      12.0V @ 2A
                                                         |             |
                                                    +----+----+        |
                                                    |         |   [360° LiDAR /
                                              [Raspberry   [Matek  Vortex Fans]
                                                 Pi 5]     H743 FC]
```

* **Capacitor Requirement:** 4S brushless motors operating at high KV (3000KV) create rapid MOSFET switching spikes that can cause resets on the Raspberry Pi 5. Soldering a **35V 1000µF Low-ESR Rubycon ZLH / Panasonic FR capacitor** across the main battery pads eliminates ESC voltage transients.
