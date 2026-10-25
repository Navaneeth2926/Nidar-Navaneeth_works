# Drone Engineering & Aerial Robotics Competition Standards

## 1. Rulebook Scrutineering Protocol
- When evaluating competition eligibility, always search and quote the verbatim rulebook text.
- Strictly distinguish between **complete airframes / RTF drones** (frequently prohibited) and **commercial off-the-shelf components** (FCs, companion computers, motors, ESCs, props).
- Verify geometric boundary conditions against launch box (e.g., 2ft x 2ft) and arena constraints (e.g., 1m corridor width).

## 2. Propulsion System & Physics Sourcing (Indian Market)
- When sizing ducted cinewhoops under 4 inches, enforce the aerodynamic scaling rule: disc area drop ($D^4$) requires higher motor KV (2700-3150KV on 4S) to maintain a $\ge 2.8:1$ thrust-to-weight ratio.
- Favor 3-blade (tri-blade) props for ducted frames to maximize disc solidity and minimize IMU vibration.
- When sourcing components under Indian Rupee (INR) budgets and strict deadlines (< 2 weeks), benchmark against verified domestic retailers:
  - Robu.in (Pune, Maharashtra — 2-4 days)
  - QuadKopter.in (Bengaluru, Karnataka — 3-5 days)
  - InsideFPV / Drkarts / Electropi (3-5 days)

## 3. Parametric CAD Modeling Deliverables
- When generating custom airframe designs for 3D printing (e.g., PETG-CF), provide:
  - An Autodesk Fusion 360 procedural Python script (`adsk.core` / `adsk.fusion`) for native CAD modification.
  - A standalone parametric OpenSCAD script (`.scad`) for instant `.stl` / `.3mf` slicing.
  - Slicer settings (nozzle material, perimeters, infill geometry, temperature) for reinforced composites and TPU dampers.
