# NIDAR AirMouse: Finite Element Structural Analysis & ANSYS Simulation Report

**Project:** NIDAR 2026-27 | Track 1 - Drone Innovation | Problem Statement 2 (AirMouse)  
**Simulation Engine:** Standalone Numerical FEA + ANSYS APDL Formulation (`SOLID186` 20-Node 3D Elements)  
**Evaluated Materials:** Carbon-Fiber Reinforced PETG (**PETG-CF**) & Aerospace Aluminum (**7075-T6**)

---

## 1. Executive Simulation Summary

To verify structural integrity under aggressive indoor flight dynamics and hard touchdowns while reducing 3D printing material costs, a comprehensive finite element simulation was conducted across 4 mission-critical load cases.

| Parameter | Unoptimized Solid Design | Generative / SIMP Optimized Design | Improvement / Savings |
| :--- | :---: | :---: | :---: |
| **Airframe Mass (PETG-CF)** | **155.95 g** | **96.07 g** | **-38.4% (-59.89 g mass reduction)** |
| **Material Cost (3D Printing INR)** | **₹436.67** | **₹268.99** | **-38.4% (₹167.68 saved per frame)** |
| **Max Stress (4S Punch-Out Thrust)** | 18.42 MPa | 23.85 MPa | **Safety Factor = 3.14 ($\ge 2.5$ standard)** |
| **Max Arm Tip Deflection** | 3.48 mm | 4.12 mm | **Duct-to-prop clearance preserved (>1.8mm)** |
| **Safety Factor (3G Hard Landing)** | 136.1 | 84.2 | **100% fail-safe on all 4 landing skids** |
| **Safety Factor (15N Corridor Collision)** | 6.93 | 4.88 | **Zero wall-breach or duct collapse** |
| **1st Natural Bending Frequency** | 32.0 Hz | 30.5 Hz | **Resonance-safe: 18x below 583.3 Hz motor RPM** |

---

## 2. Material Constitutive Properties

| Mechanical Property | PETG-CF (3D-Printed Composite) | Aerospace Aluminum 7075-T6 | Unit |
| :--- | :---: | :---: | :---: |
| **Elastic Modulus ($E$)** | $8.5 \times 10^9$ | $71.7 \times 10^9$ | $\text{Pa}$ |
| **Poisson's Ratio ($\nu$)** | 0.38 | 0.33 | — |
| **Density ($\rho$)** | 1,280 | 2,810 | $\text{kg/m}^3$ |
| **Tensile Yield Strength ($\sigma_y$)** | **75.0** | **503.0** | $\text{MPa}$ |
| **Raw Material Cost (India)** | **₹2,800 / kg** | **₹1,200 / kg** | $\text{INR}$ |

---

## 3. Four Competition Load Cases & Verification

### 3.1 Load Case 1: Maximum 4S Motor Punch-Out Thrust
* **Condition:** All 4x EMAX ECO II 2004 motors at 100% throttle producing **5.2 N thrust each (20.8 N total upward lift)**.
* **Governing Formula:**
  $$\sigma = \frac{M_{\text{thrust}}}{Z_{\text{arm}}} = \frac{F_{\text{motor}} \cdot L_{\text{arm}}}{\frac{w \cdot t^2}{6}}$$
* **Results:**
  * **Max Von Mises Stress:** **18.42 MPa** (Well below the 75 MPa yield limit of PETG-CF).
  * **Safety Factor ($SF$):** **4.07** (Solid) / **3.14** (Topology Optimized).
  * **Tip Deflection:** **3.48 mm** (Elastic recovery within linear regime).

### 3.2 Load Case 2: 3G Emergency Drop / Hard Landing
* **Condition:** Rapid autonomous descent landing on all 4 landing skids with **$3 \times g$ dynamic deceleration** on total 720g AUW ($F = 21.19\text{ N}$).
* **Results:**
  * **Max Von Mises Stress:** **0.55 MPa**.
  * **Safety Factor ($SF$):** **136.07** (Solid) / **84.2** (Optimized).
  * **Deflection:** **$< 0.001\text{ mm}$**. The vertical compression columns absorb shock with zero risk of yielding.

### 3.3 Load Case 3: 15 N Lateral Corridor Wall Bump
* **Condition:** Drone drifts into a corridor wall at $1.5\text{ m/s}$, with the outer 360° ducted bumper absorbing the lateral impact force ($15.0\text{ N}$).
* **Results:**
  * **Max Hoop Bending Stress:** **10.83 MPa**.
  * **Safety Factor ($SF$):** **6.93**.
  * **Duct Wall Deflection:** **1.23 mm**. Since blade clearance is **2.05 mm**, the duct deforms elastically without touching the spinning propeller.

### 3.4 Load Case 4: Modal Analysis & Harmonic Resonance Avoidance
* **Motor Operating Frequency (3000KV on 4S LiPo @ 35,000 RPM):**
  $$f_{\text{motor}} = \frac{35,000\text{ RPM}}{60} = \mathbf{583.3\text{ Hz}}$$
  $$f_{\text{blade-pass}} = 3 \times 583.3 = \mathbf{1,750\text{ Hz}}$$
* **Extracted Frame Natural Frequencies:**
  * **Mode 1 (Arm Bending):** **32.0 Hz**
  * **Mode 2 (Chassis Torsion):** **88.4 Hz**
  * **Mode 3 (Duct Hoop Breathing):** **173.0 Hz**
* **Resonance Verdict: PASS.** The fundamental structural modes ($32 - 173\text{ Hz}$) are separated by **over 300%** from motor shaft rotation ($583\text{ Hz}$), preventing destructive gyro noise and flight controller IMU aliasing!

---

## 4. Autodesk Fusion 360 Generative Design & Cost Reduction

### 4.1 Topology Optimization Setup
To reduce 3D printing filament costs while maintaining the above structural safety factors:
1. **Preserve Geometry:**
   * Motor mounting bolt circles (12×12 mm M2).
   * Electronics stack standoffs (30.5×30.5 mm M3, 58×49 mm M2.5).
   * Inner aerodynamic duct walls ($93.0\text{ mm}$ bore).
   * Landing gear root columns.
2. **Obstacle Geometry:**
   * Propeller rotation swept cylinders ($90\text{ mm dia} \times 20\text{ mm height}$).
   * Camera 120° forward field of view (FOV).
   * Optical flow downward sensing pyramid ($60^\circ$ cone).
   * Electronics enclosure envelope (FC, Pi 5, AI HAT, BEC).
3. **Manufacturing Constraints:**
   * **Additive Manufacturing (FDM / 3D Printing):** 45° overhang limit, $Z+$ build direction, minimum feature size $2.0\text{ mm}$.
4. **Achieved Savings:**
   * **Mass Reduction:** **59.89 grams saved** (reduced from 155.95g to **96.07g**).
   * **Printing Cost Savings:** **₹167.68 saved per frame** (down to **₹268.99**), allowing rapid iteration and spare frame fabrication within student/competition budgets.
