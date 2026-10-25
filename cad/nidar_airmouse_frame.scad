// ==============================================================================
// NIDAR AirMouse: 3.5" Metal Unibody Ducted Cinewhoop Complete Assembly
// Aerospace Aluminum 7075-T6 Chassis with EMAX ECO II 2004 Motors,
// Gemfan D90-3 Tri-Blade Propellers, and 18mm Landing Skids.
// ==============================================================================

$fn = 60; // Smooth curves for export

// ---------------------- SPECIFICATIONS & DIMENSIONS ----------------------
deck_thickness       = 3.0;  // mm (rigid aluminum chassis)
fuselage_width       = 68.0; // mm
fuselage_length      = 146.0;// mm

// Propeller: Gemfan D90-3 (3.5" / 90mm Tri-Blade)
prop_dia_mm          = 89.0; 
prop_radius          = prop_dia_mm / 2; // 44.5 mm
blade_clearance      = 2.0;  // 2.0 mm blade tip clearance
duct_inner_radius    = prop_radius + blade_clearance; // 46.5 mm (93 mm ID)
duct_wall_thick      = 2.2;  // 2.2 mm
duct_outer_radius    = duct_inner_radius + duct_wall_thick; // 48.7 mm (97.4 mm OD)
duct_height          = 26.0; // mm

// Motor Offsets (Squished-X Deadcat layout)
motor_x              = 62.0; // mm
motor_y_front        = 58.0; // mm
motor_y_rear         = 58.0; // mm

// Motor Specs: EMAX ECO II 2004 3000KV
motor_bell_radius    = 12.35; // 24.7 mm outer bell diameter
motor_base_height    = 3.5;   // mm
motor_bell_height    = 9.5;   // mm
motor_shaft_radius   = 2.5;   // 5.0 mm shaft diameter
motor_shaft_height   = 5.0;   // mm

// Landing Gear: 18mm ground clearance
leg_height           = 18.0;  // mm
leg_radius           = 4.5;   // mm
foot_radius          = 8.5;   // mm
foot_height          = 3.0;   // mm

// Stacks
fc_stack_spacing     = 30.5;  // M3 Matek H743-WLITE
pi5_hole_x           = 49.0;  // M2.5 Raspberry Pi 5
pi5_hole_y           = 58.0;

// ---------------------- MODULE DEFINITIONS ----------------------

// 1. Central Fuselage Chassis
module central_chassis() {
    color([0.35, 0.38, 0.42]) { // Anodized Aerospace Aluminum 7075
        difference() {
            // Main fuselage plate
            cube([fuselage_width, fuselage_length, deck_thickness], center = true);
            
            // Matek H743 30.5x30.5mm M3 Holes
            for (dx = [-fc_stack_spacing/2, fc_stack_spacing/2]) {
                for (dy = [-fc_stack_spacing/2, fc_stack_spacing/2]) {
                    translate([dx, dy, 0]) cylinder(r = 1.6, h = 10, center = true);
                }
            }
            // Raspberry Pi 5 58x49mm M2.5 Holes
            for (dx = [-pi5_hole_x/2, pi5_hole_x/2]) {
                for (dy = [-pi5_hole_y/2, pi5_hole_y/2]) {
                    translate([dx, dy, 0]) cylinder(r = 1.3, h = 10, center = true);
                }
            }
            // MicoAir MTF-01 Optical Flow / ToF Center Window
            cube([26.0, 18.0, 10], center = true);
            
            // Battery Strap Cutouts
            translate([0, 32, 0]) cube([22.0, 3.5, 10], center = true);
            translate([0, -32, 0]) cube([22.0, 3.5, 10], center = true);
        }
    }
}

// 2. Ducted Shroud & Motor Pod with Stator Arms
module ducted_pod_and_arm(mx, my) {
    color([0.4, 0.42, 0.46]) {
        translate([mx, my, 0]) {
            // Duct Shroud
            difference() {
                cylinder(r = duct_outer_radius, h = duct_height, center = true);
                cylinder(r = duct_inner_radius, h = duct_height + 2, center = true);
            }
            // Central Motor Hub Plate
            translate([0, 0, -duct_height/2 + deck_thickness/2]) {
                difference() {
                    cylinder(r = 10.0, h = deck_thickness, center = true);
                    cylinder(r = 2.5, h = 10, center = true); // Shaft hole
                    // 12x12mm M2 motor mounting pattern
                    for (dx = [-6, 6]) {
                        for (dy = [-6, 6]) {
                            translate([dx, dy, 0]) cylinder(r = 1.1, h = 10, center = true);
                        }
                    }
                }
                // 3x Aerodynamic Stator Struts
                for (a = [30, 150, 270]) {
                    rotate([0, 0, a])
                        translate([duct_inner_radius/2, 0, 0])
                        cube([duct_inner_radius, 2.5, deck_thickness], center = true);
                }
            }
        }
        // Connecting Arm Truss
        hull() {
            translate([mx * 0.4, my * 0.5, -duct_height/2 + deck_thickness/2])
                cube([15, 12, deck_thickness], center = true);
            translate([mx * 0.9, my * 0.9, -duct_height/2 + deck_thickness/2])
                cylinder(r = 8, h = deck_thickness, center = true);
        }
    }
}

// 3. EMAX ECO II 2004 3000KV Brushless Motor
module emax_motor(mx, my) {
    translate([mx, my, -duct_height/2 + deck_thickness]) {
        // Motor Base (Satin Steel)
        color([0.25, 0.25, 0.28])
            cylinder(r = 11.0, h = motor_base_height);
        
        // Motor Rotor Bell (Anodized Gunmetal Aluminum)
        color([0.15, 0.15, 0.18])
            translate([0, 0, motor_base_height])
            cylinder(r = motor_bell_radius, h = motor_bell_height);
            
        // 5mm Output Prop Shaft (Polished Steel)
        color([0.85, 0.85, 0.90])
            translate([0, 0, motor_base_height + motor_bell_height])
            cylinder(r = motor_shaft_radius, h = motor_shaft_height);
    }
}

// 4. Gemfan D90-3 (3.5" Tri-Blade) Propeller
module gemfan_d90_propeller(mx, my) {
    prop_z = -duct_height/2 + deck_thickness + motor_base_height + motor_bell_height + 1.0;
    translate([mx, my, prop_z]) {
        color([0.0, 0.75, 0.90, 0.85]) { // Translucent Cyan Polycarbonate
            // Central Propeller Hub
            cylinder(r = 6.0, h = 3.5, center = true);
            
            // 3 Pitched Blades at 120°
            for (a = [0, 120, 240]) {
                rotate([0, 0, a]) {
                    translate([prop_radius / 2 + 3, 0, 0])
                        rotate([12, 0, 0]) // Aerodynamic pitch angle
                        cube([prop_radius - 5, 7.5, 1.8], center = true);
                }
            }
        }
    }
}

// 5. Landing Legs (18mm Ground Clearance)
module landing_leg(mx, my) {
    leg_x = mx + (mx > 0 ? 8 : -8);
    leg_y = my + (my > 0 ? 8 : -8);
    base_z = -duct_height/2;
    
    color([0.3, 0.32, 0.35]) { // Aerospace Aluminum Strut
        // Downward Strut
        translate([leg_x, leg_y, base_z - leg_height/2])
            cylinder(r = leg_radius, h = leg_height, center = true);
        // Stable Base Foot Pad
        translate([leg_x, leg_y, base_z - leg_height - foot_height/2])
            cylinder(r = foot_radius, h = foot_height, center = true);
    }
}

// ==============================================================================
// COMPLETE MONOLITHIC ASSEMBLY
// ==============================================================================
module complete_nidar_airmouse() {
    // 1. Central Chassis
    translate([0, 0, -duct_height/2 + deck_thickness/2])
        central_chassis();
        
    // 2. 4x Ducts, Motors, Props & Landing Legs
    positions = [
        [ motor_x,  motor_y_front],
        [-motor_x,  motor_y_front],
        [ motor_x, -motor_y_rear],
        [-motor_x, -motor_y_rear]
    ];
    
    for (pos = positions) {
        ducted_pod_and_arm(pos[0], pos[1]);
        emax_motor(pos[0], pos[1]);
        gemfan_d90_propeller(pos[0], pos[1]);
        landing_leg(pos[0], pos[1]);
    }
}

// Render complete drone assembly
complete_nidar_airmouse();
