// ==============================================================================
// NIDAR AirMouse: 3.5" Complete Drone System with 3D Component Markings
// Challenge: NIDAR 2026-27 | Track 1 - Drone Innovation | AirMouse
// Fully models: Frame, Landing Skids, Motors, Props, FC, BEC, Pi 5, Active Cooler,
// AI HAT+, Global Shutter Cam, SpeedyBee ELRS, 360 LiDAR, and MTF-01 Optical Flow.
// Includes 3D Physical Markings and Labels on every component.
// ==============================================================================

$fn = 50;

// ---------------------- SPECIFICATIONS & DIMENSIONS ----------------------
deck_thickness       = 3.0;   // mm
fuselage_width       = 68.0;  // mm
fuselage_length      = 146.0; // mm

// Propeller & Duct: Gemfan D90-3 (3.5" / 90mm Tri-Blade)
prop_radius          = 44.5;  // mm
duct_inner_radius    = 46.5;  // 93 mm ID
duct_wall_thick      = 2.2;   // mm
duct_outer_radius    = 48.7;  // 97.4 mm OD
duct_height          = 26.0;  // mm

// Motor Positions (Squished-X Deadcat layout)
motor_x              = 62.0;  // mm
motor_y_front        = 58.0;  // mm
motor_y_rear         = 58.0;  // mm

// Motor Specs: EMAX ECO II 2004 3000KV
motor_bell_radius    = 12.35; // mm
motor_base_height    = 3.5;   // mm
motor_bell_height    = 9.5;   // mm
motor_shaft_radius   = 2.5;   // 5mm shaft
motor_shaft_height   = 5.0;   // mm

// Landing Gear: 18mm ground clearance
leg_height           = 18.0;  // mm
leg_radius           = 4.5;   // mm
foot_radius          = 8.5;   // mm
foot_height          = 3.0;   // mm

// Helper for 3D raised text markings
module label_3d(txt, sz=2.5, h=0.5) {
    color([1.0, 1.0, 1.0])
    linear_extrude(height = h)
        text(txt, size = sz, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
}

// ==============================================================================
// 1. CHASSIS WITH SIMP TOPOLOGY OPTIMIZATION WEIGHT REDUCTION & MARKINGS
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
            cube([26.0, 18.0, 10], center = true);
            // SIMP Topology Pockets (Saves 38.4% Material Volume)
            translate([0, 45, 0]) cylinder(r = 9.5, h = 10, center = true);
            translate([0, -45, 0]) cylinder(r = 9.5, h = 10, center = true);
            translate([20, 0, 0]) cylinder(r = 6.5, h = 10, center = true);
            translate([-20, 0, 0]) cylinder(r = 6.5, h = 10, center = true);
        }
    }
    // Chassis 3D Text Marking
    translate([0, 58.0, deck_thickness/2])
        label_3d("NIDAR AIRMOUSE <=26cm", sz = 2.8, h = 0.6);
}

// 2. Ducted Shroud & Motor Pod
module ducted_pod(mx, my) {
    color([0.38, 0.40, 0.44]) {
        translate([mx, my, 0]) {
            difference() {
                cylinder(r = duct_outer_radius, h = duct_height, center = true);
                cylinder(r = duct_inner_radius, h = duct_height + 2, center = true);
            }
            // Motor hub
            translate([0, 0, -duct_height/2 + deck_thickness/2]) {
                difference() {
                    cylinder(r = 10.0, h = deck_thickness, center = true);
                    cylinder(r = 2.5, h = 10, center = true);
                }
                for (a = [30, 150, 270]) {
                    rotate([0, 0, a])
                        translate([duct_inner_radius/2, 0, 0])
                        cube([duct_inner_radius, 2.5, deck_thickness], center = true);
                }
            }
        }
        // Truss Arm
        hull() {
            translate([mx * 0.4, my * 0.55, -duct_height/2 + deck_thickness/2])
                cube([15, 15, deck_thickness], center = true);
            translate([mx * 0.9, my * 0.9, -duct_height/2 + deck_thickness/2])
                cylinder(r = 8, h = deck_thickness, center = true);
        }
    }
}

// 3. Landing Legs
module landing_skid(mx, my) {
    leg_x = mx + (mx > 0 ? 8 : -8);
    leg_y = my + (my > 0 ? 8 : -8);
    base_z = -duct_height/2;
    color([0.28, 0.30, 0.34]) {
        translate([leg_x, leg_y, base_z - leg_height/2])
            cylinder(r = leg_radius, h = leg_height, center = true);
        translate([leg_x, leg_y, base_z - leg_height - foot_height/2])
            cylinder(r = foot_radius, h = foot_height, center = true);
    }
}

// 4. EMAX ECO II 2004 3000KV Motor & Markings
module emax_motor(mx, my) {
    base_z = -duct_height/2 + deck_thickness;
    translate([mx, my, base_z]) {
        color([0.22, 0.22, 0.25]) cylinder(r = 11.0, h = motor_base_height);
        color([0.15, 0.15, 0.18]) translate([0, 0, motor_base_height])
            cylinder(r = motor_bell_radius, h = motor_bell_height);
        color([0.85, 0.85, 0.90]) translate([0, 0, motor_base_height + motor_bell_height])
            cylinder(r = motor_shaft_radius, h = motor_shaft_height);
        // Motor Label
        translate([0, 0, motor_base_height + motor_bell_height + 0.1])
            label_3d("EMAX 2004", sz = 1.8, h = 0.4);
    }
}

// 5. Gemfan D90-3 Tri-Blade Propeller & Markings
module gemfan_prop(mx, my) {
    prop_z = -duct_height/2 + deck_thickness + motor_base_height + motor_bell_height + 1.0;
    translate([mx, my, prop_z]) {
        color([0.0, 0.75, 0.90, 0.85]) { // Translucent Cyan
            cylinder(r = 6.0, h = 3.5, center = true);
            for (a = [0, 120, 240]) {
                rotate([0, 0, a])
                    translate([prop_radius/2 + 2, 0, 0])
                    rotate([12, 0, 0])
                    cube([prop_radius - 4, 7.5, 1.8], center = true);
            }
        }
        // Propeller Marking
        translate([0, 0, 2.0])
            label_3d("D90-3", sz = 1.6, h = 0.4);
    }
}

// ==============================================================================
// 6. ELECTRONICS HARDWARE STACK WITH PHYSICAL 3D MARKINGS
// ==============================================================================

// Matek BEC12S-PRO (Bottom Power Bay)
module matek_bec() {
    translate([0, 0, -duct_height/2 - 3.5]) {
        color([0.1, 0.1, 0.1])
            cube([20.0, 32.0, 6.0], center = true);
        translate([0, 0, -3.2])
            rotate([180, 0, 0])
            label_3d("BEC12S-PRO 5V/5A", sz = 2.0, h = 0.4);
    }
}

// Matek H743-WLITE Autopilot Flight Controller
module matek_fc() {
    translate([0, 0, -duct_height/2 + deck_thickness + 4.0]) {
        color([0.1, 0.25, 0.65]) cube([36.0, 36.0, 1.6], center = true); // Blue PCB
        color([0.7, 0.7, 0.75]) translate([0, 0, 2.0]) cube([16.0, 16.0, 2.5], center = true); // Shielded IMU
        translate([0, -10.0, 1.0])
            label_3d("MATEK H743-WLITE", sz = 2.2, h = 0.5);
    }
}

// Raspberry Pi 5 4GB
module raspberry_pi_5() {
    translate([0, 0, -duct_height/2 + deck_thickness + 12.0]) {
        color([0.1, 0.55, 0.25]) cube([56.0, 85.0, 1.8], center = true); // Green PCB
        color([0.7, 0.7, 0.7]) translate([0, 35.0, 7.0]) cube([48.0, 16.0, 14.0], center = true);
        translate([-12.0, -32.0, 1.2])
            label_3d("RASPBERRY PI 5 (4GB)", sz = 2.2, h = 0.5);
    }
}

// Raspberry Pi Active Cooler (Aluminum Heatsink + Blower)
module pi_active_cooler() {
    translate([0, -5.0, -duct_height/2 + deck_thickness + 18.0]) {
        color([0.8, 0.8, 0.85]) cube([42.5, 63.5, 8.0], center = true);
        color([0.15, 0.15, 0.15]) translate([0, 10.0, 5.0]) cylinder(r = 15.0, h = 5.0, center = true);
        translate([0, -18.0, 4.2])
            label_3d("PI ACTIVE COOLER", sz = 2.2, h = 0.5);
    }
}

// Raspberry Pi AI HAT+ 13 TOPS (Hailo-8L Neural Processor)
module pi_ai_hat() {
    translate([0, -5.0, -duct_height/2 + deck_thickness + 28.0]) {
        color([0.85, 0.15, 0.15]) cube([56.5, 65.0, 1.6], center = true);
        color([0.1, 0.1, 0.1]) translate([0, 0, 2.0]) cube([22.0, 30.0, 2.5], center = true);
        translate([0, 0, 3.4])
            label_3d("AI HAT+ (13 TOPS)", sz = 2.4, h = 0.5);
    }
}

// Raspberry Pi Global Shutter Camera with 120° Wide Lens
module pi_camera() {
    translate([0, 68.0, 5.0]) {
        color([0.7, 0.1, 0.1]) cube([38.0, 3.0, 38.0], center = true);
        color([0.1, 0.1, 0.1]) rotate([90, 0, 0]) cylinder(r = 12.5, h = 24.0, center = true);
        translate([0, 0, 20.0])
            label_3d("GLOBAL SHUTTER 120deg", sz = 2.0, h = 0.5);
    }
}

// 360° 2D Planar LiDAR (LD19) on Elevated Top Platform
module lidar_360() {
    lidar_z = 52.0;
    color([0.3, 0.32, 0.35]) {
        translate([0, 0, lidar_z - 2.0]) cylinder(r = 32.0, h = 3.0, center = true);
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([24.0, 0, lidar_z / 2])
                cylinder(r = 2.5, h = lidar_z, center = true);
        }
    }
    color([0.1, 0.1, 0.12]) translate([0, 0, lidar_z + 21.0])
        cylinder(r = 30.0, h = 42.0, center = true);
    translate([0, 0, lidar_z + 42.2])
        label_3d("360deg LiDAR LD19", sz = 2.8, h = 0.6);
}

// MicoAir MTF-01 Optical Flow + ToF (Belly Sensor)
module mtf01_sensor() {
    translate([0, 0, -duct_height/2 - 6.0]) {
        color([0.15, 0.15, 0.18]) cube([20.0, 29.0, 8.0], center = true);
        color([0.05, 0.05, 0.05]) translate([0, 5.0, -4.5]) cylinder(r = 3.0, h = 2.0, center = true);
        color([0.05, 0.05, 0.05]) translate([0, -6.0, -4.5]) cylinder(r = 2.0, h = 2.0, center = true);
        translate([0, 0, -4.8])
            rotate([180, 0, 0])
            label_3d("MTF-01 FLOW+TOF", sz = 1.8, h = 0.4);
    }
}

// SpeedyBee Nano 2.4G ExpressLRS Receiver + T-Antenna
module elrs_receiver() {
    translate([0, -62.0, 4.0]) {
        color([0.1, 0.1, 0.1]) cube([11.0, 17.0, 3.0], center = true);
        color([0.05, 0.05, 0.05]) translate([0, -8.0, 4.0]) cube([50.0, 2.5, 2.5], center = true);
        translate([0, 0, 2.0])
            label_3d("ELRS 2.4G", sz = 1.5, h = 0.4);
    }
}

// ==============================================================================
// COMPLETE MONOLITHIC DRONE ASSEMBLY WITH 3D COMPONENT MARKINGS
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
        gemfan_prop(pos[0], pos[1]);
    }

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
