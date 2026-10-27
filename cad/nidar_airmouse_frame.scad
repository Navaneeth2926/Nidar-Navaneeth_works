// ==============================================================================
// NIDAR AirMouse: 5-Inch 6S Complete Drone System with 3D Component Markings
// Challenge: NIDAR 2026-27 | Track 1 - Drone Innovation | AirMouse
// Fully models: 5" Frame, Landing Skids, EMAX 2306 1700KV Motors, 5030 Props,
// Molicel 6S1P 5000mAh Battery, FC, BEC, Pi 5, Active Cooler, AI HAT+, Camera,
// SpeedyBee ELRS, 360 LiDAR, and MTF-01 Optical Flow.
// ==============================================================================

$fn = 50;

// ---------------------- SPECIFICATIONS & DIMENSIONS ----------------------
deck_thickness       = 3.5;   // mm
fuselage_width       = 76.0;  // mm
fuselage_length      = 192.0; // mm

// Propeller & Protective Duct Guard: 5.0" (127 mm) Tri-Blade
prop_radius          = 63.5;  // mm (127 mm / 5.0 inch diameter)
duct_inner_radius    = 66.5;  // 133 mm ID (3mm blade clearance)
duct_wall_thick      = 2.5;   // mm
duct_outer_radius    = 69.0;  // 138 mm OD
duct_height          = 28.0;  // mm

// Motor Positions (5-Inch Squished-X Deadcat layout, 260 mm Wheelbase)
motor_x              = 94.0;  // mm
motor_y_front        = 88.0;  // mm
motor_y_rear         = 92.0;  // mm

// Motor Specs: EMAX ECO II 2306 1700KV
motor_bell_radius    = 13.95; // mm (27.9 mm outer diameter)
motor_base_height    = 3.8;   // mm
motor_bell_height    = 12.5;  // mm
motor_shaft_radius   = 2.5;   // 5mm M5 shaft
motor_shaft_height   = 11.0;  // mm

// Landing Gear: 24mm ground clearance (protects 6S battery & belly sensor)
leg_height           = 24.0;  // mm
leg_radius           = 5.2;   // mm
foot_radius          = 10.5;  // mm
foot_height          = 3.5;   // mm

// Helper for 3D raised text markings
module label_3d(txt, sz=2.5, h=0.5) {
    color([1.0, 1.0, 1.0])
    linear_extrude(height = h)
        text(txt, size = sz, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
}

// ==============================================================================
// 1. 5-INCH CHASSIS WITH SIMP TOPOLOGY OPTIMIZATION WEIGHT REDUCTION & MARKINGS
// ==============================================================================
module chassis_deck() {
    color([0.32, 0.35, 0.38]) { // Anodized Aerospace Aluminum / PETG-CF
        difference() {
            cube([fuselage_width, fuselage_length, deck_thickness], center = true);
            // Flight Controller 30.5x30.5mm M3 Holes
            for (dx = [-15.25, 15.25]) {
                for (dy = [-15.25, 15.25]) {
                    translate([dx, dy, 0]) cylinder(r = 1.6, h = 10, center = true);
                }
            }
            // Raspberry Pi 5 58x49mm M2.5 Holes
            for (dx = [-24.5, 24.5]) {
                for (dy = [-29.0, 29.0]) {
                    translate([dx, dy, 0]) cylinder(r = 1.3, h = 10, center = true);
                }
            }
            // Belly Window for MTF-01 Optical Flow + ToF Sensor
            translate([0, 52.0, 0]) cube([30.0, 22.0, 10], center = true);
            // SIMP Topology Pockets
            translate([0, 65, 0]) cylinder(r = 11.5, h = 10, center = true);
            translate([0, -35, 0]) cylinder(r = 11.5, h = 10, center = true);
            translate([0, -65, 0]) cylinder(r = 11.5, h = 10, center = true);
            translate([24, 0, 0]) cylinder(r = 8.5, h = 10, center = true);
            translate([-24, 0, 0]) cylinder(r = 8.5, h = 10, center = true);
        }
    }
    // Chassis 3D Text Marking
    translate([0, 78.0, deck_thickness/2])
        label_3d("NIDAR AIRMOUSE 5IN 6S", sz = 3.2, h = 0.6);
}

// 2. 5-Inch Ducted Shroud & Motor Pod
module ducted_pod(mx, my) {
    color([0.38, 0.40, 0.44]) {
        translate([mx, my, 0]) {
            difference() {
                cylinder(r = duct_outer_radius, h = duct_height, center = true);
                cylinder(r = duct_inner_radius, h = duct_height + 2, center = true);
            }
            // Motor hub (16x16mm M3 pattern base)
            translate([0, 0, -duct_height/2 + deck_thickness/2]) {
                difference() {
                    cylinder(r = 14.0, h = deck_thickness, center = true);
                    cylinder(r = 3.0, h = 10, center = true);
                }
                for (a = [30, 150, 270]) {
                    rotate([0, 0, a])
                        translate([duct_inner_radius/2, 0, 0])
                        cube([duct_inner_radius, 3.2, deck_thickness], center = true);
                }
            }
        }
        // Truss Arm
        hull() {
            translate([mx * 0.4, my * 0.55, -duct_height/2 + deck_thickness/2])
                cube([20, 20, deck_thickness], center = true);
            translate([mx * 0.9, my * 0.9, -duct_height/2 + deck_thickness/2])
                cylinder(r = 12, h = deck_thickness, center = true);
        }
    }
}

// 3. Sturdy Landing Legs
module landing_skid(mx, my) {
    leg_x = mx + (mx > 0 ? 11 : -11);
    leg_y = my + (my > 0 ? 11 : -11);
    base_z = -duct_height/2;
    color([0.28, 0.30, 0.34]) {
        translate([leg_x, leg_y, base_z - leg_height/2])
            cylinder(r = leg_radius, h = leg_height, center = true);
        translate([leg_x, leg_y, base_z - leg_height - foot_height/2])
            cylinder(r = foot_radius, h = foot_height, center = true);
    }
}

// 4. EMAX ECO II 2306 1700KV Motor & Markings
module emax_motor(mx, my) {
    base_z = -duct_height/2 + deck_thickness;
    translate([mx, my, base_z]) {
        color([0.22, 0.22, 0.25]) cylinder(r = 13.0, h = motor_base_height);
        color([0.15, 0.15, 0.18]) translate([0, 0, motor_base_height])
            cylinder(r = motor_bell_radius, h = motor_bell_height);
        color([0.85, 0.85, 0.90]) translate([0, 0, motor_base_height + motor_bell_height])
            cylinder(r = motor_shaft_radius, h = motor_shaft_height);
        // Motor Label
        translate([0, 0, motor_base_height + motor_bell_height + 0.1])
            label_3d("EMAX 2306 1700KV", sz = 2.0, h = 0.4);
    }
}

// 5. 5.0" Tri-Blade Propeller & Markings (HQProp 5030-3)
module prop_5in(mx, my) {
    prop_z = -duct_height/2 + deck_thickness + motor_base_height + motor_bell_height + 1.2;
    translate([mx, my, prop_z]) {
        color([0.0, 0.75, 0.90, 0.85]) { // Translucent Cyan
            cylinder(r = 8.5, h = 4.0, center = true);
            for (a = [0, 120, 240]) {
                rotate([0, 0, a])
                    translate([prop_radius/2 + 2, 0, 0])
                    rotate([12, 0, 0])
                    cube([prop_radius - 6, 9.5, 2.2], center = true);
            }
        }
        translate([0, 0, 2.2])
            label_3d("HQPROP 5030-3 (5IN)", sz = 1.8, h = 0.4);
    }
}

// 6. Molicel INR21700-P50B 6S1P 5000mAh Battery Pack & Markings
module molicel_battery_pack() {
    bat_z = -deck_thickness/2 - 21.5/2 - 1.5;
    translate([0, -10.0, bat_z]) {
        color([0.95, 0.80, 0.10]) { // Yellow heatshrink
            cube([64.5, 73.0, 21.5], center = true);
        }
        // XT60 Plug
        color([0.9, 0.75, 0.05])
            translate([0, -73.0/2 - 7.5, 0])
            cube([17.0, 15.0, 10.0], center = true);
        // Battery Label
        translate([0, 0, -21.5/2 - 0.2])
            rotate([180, 0, 0])
            label_3d("MOLICEL 6S1P 5000mAh (P50B)", sz = 2.8, h = 0.5);
    }
}

// 7. Matek BEC12S-PRO
module matek_bec() {
    translate([0, -35.0, deck_thickness/2 + 3.0]) {
        color([0.15, 0.15, 0.18]) cube([22.0, 26.0, 6.0], center = true);
        translate([0, 0, 3.2])
            label_3d("BEC12S-PRO (5V/5A)", sz = 1.8, h = 0.4);
    }
}

// 8. Matek H743-WLITE Autopilot Flight Controller
module matek_fc() {
    translate([0, 0, deck_thickness/2 + 5.0]) {
        color([0.08, 0.35, 0.65]) cube([36.0, 36.0, 5.0], center = true);
        translate([0, 0, 2.7])
            label_3d("MATEK H743-WLITE", sz = 2.4, h = 0.4);
    }
}

// 9. Raspberry Pi 5 (4GB RAM)
module raspberry_pi_5() {
    translate([0, 0, deck_thickness/2 + 13.0]) {
        color([0.12, 0.50, 0.22]) cube([56.0, 85.0, 1.8], center = true);
        color([0.7, 0.7, 0.7]) translate([0, 36.0, 7.0]) cube([48.0, 13.0, 14.0], center = true);
        translate([-12.0, -32.0, 1.1])
            label_3d("RASPBERRY PI 5 (4GB)", sz = 2.2, h = 0.4);
    }
}

// 10. Raspberry Pi Active Cooler
module pi_active_cooler() {
    translate([0, -18.0, deck_thickness/2 + 15.0]) {
        color([0.75, 0.75, 0.78]) cube([42.0, 63.0, 13.5], center = true);
        translate([0, 0, 7.0])
            label_3d("PI ACTIVE COOLER", sz = 2.2, h = 0.4);
    }
}

// 11. Raspberry Pi AI HAT+ 13 TOPS
module pi_ai_hat() {
    translate([0, 0, deck_thickness/2 + 30.0]) {
        color([0.1, 0.1, 0.1]) cube([56.0, 65.0, 2.0], center = true);
        color([0.7, 0.6, 0.1]) translate([0, 0, 1.8]) cube([16.0, 16.0, 1.5], center = true);
        translate([0, 0, 1.2])
            label_3d("AI HAT+ (13 TOPS)", sz = 2.4, h = 0.4);
    }
}

// 12. Raspberry Pi Global Shutter Camera
module pi_camera() {
    translate([0, 85.5, deck_thickness/2 + 9.0]) {
        color([0.8, 0.1, 0.1]) cube([38.0, 6.0, 22.0], center = true);
        color([0.2, 0.2, 0.2]) translate([0, 9.0, 0])
            rotate([90, 0, 0]) cylinder(r = 12.5, h = 18.0, center = true);
        translate([0, 0, 11.2])
            label_3d("GLOBAL SHUTTER CAM (120deg)", sz = 2.0, h = 0.4);
    }
}

// 13. 360° 2D Planar LiDAR (LD19)
module lidar_360() {
    translate([0, 0, 54.0]) {
        color([0.15, 0.15, 0.18]) cylinder(r = 30.0, h = 42.0, center = true);
        color([0.05, 0.05, 0.05]) translate([0, 0, 15.0]) cylinder(r = 28.0, h = 12.0, center = true);
        translate([0, 0, 21.2])
            label_3d("360deg LiDAR LD19", sz = 2.6, h = 0.4);
    }
    // 4 Pylon Standoffs
    for (a = [45, 135, 225, 315]) {
        rotate([0, 0, a])
            translate([24.0, 0, 27.0])
            color([0.3, 0.3, 0.3]) cylinder(r = 2.8, h = 54.0, center = true);
    }
}

// 14. MicoAir MTF-01 Optical Flow + ToF (Belly Sensor)
module mtf01_sensor() {
    translate([0, 52.0, -duct_height/2 - 6.0]) {
        color([0.15, 0.15, 0.18]) cube([20.0, 29.0, 8.0], center = true);
        color([0.05, 0.05, 0.05]) translate([0, 5.0, -4.5]) cylinder(r = 3.0, h = 2.0, center = true);
        color([0.05, 0.05, 0.05]) translate([0, -6.0, -4.5]) cylinder(r = 2.0, h = 2.0, center = true);
        translate([0, 0, -4.8])
            rotate([180, 0, 0])
            label_3d("MTF-01 FLOW+TOF", sz = 1.8, h = 0.4);
    }
}

// 15. SpeedyBee Nano 2.4G ExpressLRS Receiver + T-Antenna
module elrs_receiver() {
    translate([0, -83.0, deck_thickness/2 + 2.0]) {
        color([0.1, 0.1, 0.1]) cube([11.0, 17.0, 3.5], center = true);
        color([0.05, 0.05, 0.05]) translate([0, -8.0, 4.0]) cube([50.0, 2.5, 2.5], center = true);
        translate([0, 0, 2.0])
            label_3d("ELRS 2.4G", sz = 1.5, h = 0.4);
    }
}

// ==============================================================================
// COMPLETE MONOLITHIC 5-INCH DRONE ASSEMBLY WITH 3D COMPONENT MARKINGS
// ==============================================================================
module complete_nidar_airmouse_system() {
    chassis_deck();

    positions = [
        [ motor_x,  motor_y_front],
        [-motor_x,  motor_y_front],
        [ motor_x, -motor_y_rear],
        [-motor_x, -motor_y_rear]
    ];
    for (pos = positions) {
        ducted_pod(pos[0], pos[1]);
        landing_skid(pos[0], pos[1]);
        emax_motor(pos[0], pos[1]);
        prop_5in(pos[0], pos[1]);
    }

    molicel_battery_pack();
    matek_bec();
    matek_fc();
    raspberry_pi_5();
    pi_active_cooler();
    pi_ai_hat();
    pi_camera();
    lidar_360();
    mtf01_sensor();
    elrs_receiver();
}

complete_nidar_airmouse_system();
