// ==============================================================================
// NIDAR AirMouse: Custom 3.5" Ducted Unibody Cinewhoop Frame
// Optimized for GPS-Denied Indoor Search & Mapping Challenge
// Material: PETG-CF (Carbon Fiber Reinforced PETG) + TPU 95A Dampers
// ==============================================================================

$fn = 60; // Smooth curves for export

// ---------------------- GLOBAL PARAMETERS ----------------------
prop_diameter_inch   = 3.5;
prop_radius_mm       = (prop_diameter_inch * 25.4) / 2; // ~44.45 mm
blade_clearance      = 2.05; // mm tip clearance
duct_inner_radius    = prop_radius_mm + blade_clearance; // 46.5 mm (93 mm ID)
duct_wall_thick      = 2.2;  // mm (rigid PETG-CF wall)
duct_outer_radius    = duct_inner_radius + duct_wall_thick; // 48.7 mm (97.4 mm OD)
duct_height          = 26.0; // mm

// Wheelbase & Motor Spacing (Deadcat/Squished-X for zero prop in camera FOV)
motor_x_offset       = 62.0; // mm from center
motor_y_front        = 58.0; // mm front offset
motor_y_rear         = 58.0; // mm rear offset
motor_mount_circle   = 12.0; // mm PCD (standard 2004/2204 12x12mm)
motor_mount_hole_dia = 2.2;  // M2 clearance
motor_center_hole    = 5.5;  // mm center shaft/c-clip hole

// Fuselage Plate Dimensions
deck_thickness       = 3.2;  // mm
fuselage_width       = 68.0; // mm
fuselage_length      = 150.0;// mm

// Mounting Stack Specifications
// Matek H743-WLITE & 4-in-1 ESC Stack: 30.5 x 30.5 mm & 20 x 20 mm
stack_305_spacing    = 30.5;
stack_200_spacing    = 20.0;

// Raspberry Pi 5 + AI HAT+ Stack: 58.0 x 49.0 mm (M2.5)
pi5_hole_x           = 49.0;
pi5_hole_y           = 58.0;

// LiDAR Top Platform Riser
lidar_mount_spacing  = 34.0; // M2.5 pattern for LD19 / RPLIDAR C1
lidar_riser_height   = 28.0; // Clear of 360 deg prop duct plane

// Optical Flow / Downward ToF Mount (MicoAir MTF-01 / Matek 3901-L0X)
mtf01_hole_x         = 24.0;
mtf01_hole_y         = 32.0;

// ---------------------- MODULE DEFINITIONS ----------------------

// 1. Aerodynamic Ducted Shroud with Flared Bellmouth Lip
module duct_shroud() {
    difference() {
        union() {
            // Main cylindrical duct wall
            cylinder(r = duct_outer_radius, h = duct_height, center = true);
            // Flared aerodynamic bellmouth inlet lip
            translate([0, 0, duct_height/2 - 1.5])
                rotate_extrude()
                translate([duct_outer_radius - 1.2, 0, 0])
                circle(r = 2.5);
            // Outer bumper rib for wall collision protection
            translate([0, 0, 0])
                rotate_extrude()
                translate([duct_outer_radius, 0, 0])
                circle(r = 1.8);
        }
        // Inner aerodynamic bore
        cylinder(r = duct_inner_radius, h = duct_height + 4, center = true);
    }
}

// 2. Motor Pod and SIMP-Optimized Aerodynamic Stator Struts
module motor_pod_and_struts() {
    // Central motor hub
    difference() {
        cylinder(r = 9.0, h = deck_thickness + 1.5, center = true);
        // Center shaft hole
        cylinder(r = motor_center_hole / 2, h = 10, center = true);
        // 4x 12x12mm M2 motor mounting holes
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([motor_mount_circle / 2, 0, 0])
                cylinder(r = motor_mount_hole_dia / 2, h = 10, center = true);
        }
    }
    
    // 3x Aerodynamic teardrop stator struts connecting motor hub to duct wall
    for (ang = [0, 120, 240]) {
        rotate([0, 0, ang]) {
            translate([duct_inner_radius / 2, 0, -duct_height/4])
                cube([duct_inner_radius, 2.8, deck_thickness + 1.0], center = true);
        }
    }
}

// 3. Single Assembled Propeller Nacelle / Corner
module ducted_motor_corner(x_pos, y_pos) {
    translate([x_pos, y_pos, 0]) {
        duct_shroud();
        translate([0, 0, -duct_height/2 + deck_thickness/2 + 1.0])
            motor_pod_and_struts();
    }
}

// 4. Central Fuselage Core with Component Cutouts & Mounting Holes
module central_fuselage() {
    difference() {
        // Main deck body with filleted corners
        hull() {
            translate([0, 45, 0]) cylinder(r = 18, h = deck_thickness, center = true);
            translate([0, -45, 0]) cylinder(r = 18, h = deck_thickness, center = true);
            translate([fuselage_width/2 - 6, 0, 0]) cube([12, fuselage_length - 30, deck_thickness], center = true);
            translate([-fuselage_width/2 + 6, 0, 0]) cube([12, fuselage_length - 30, deck_thickness], center = true);
        }
        
        // Matek H743-WLITE & ESC 30.5x30.5mm mounting holes
        for (dx = [-stack_305_spacing/2, stack_305_spacing/2]) {
            for (dy = [-stack_305_spacing/2, stack_305_spacing/2]) {
                translate([dx, dy, 0]) cylinder(r = 1.6, h = 15, center = true); // M3
            }
        }
        
        // 20x20mm secondary mounting holes
        for (dx = [-stack_200_spacing/2, stack_200_spacing/2]) {
            for (dy = [-stack_200_spacing/2, stack_200_spacing/2]) {
                translate([dx, dy, 0]) cylinder(r = 1.3, h = 15, center = true); // M2.5
            }
        }
        
        // Raspberry Pi 5 Mounting Holes (58.0 x 49.0 mm M2.5)
        for (dx = [-pi5_hole_x/2, pi5_hole_x/2]) {
            for (dy = [-pi5_hole_y/2, pi5_hole_y/2]) {
                translate([dx, dy, 0]) cylinder(r = 1.4, h = 15, center = true);
            }
        }
        
        // Optical Flow & Downward ToF Window Cutout (Center belly)
        translate([0, 5, 0]) {
            cube([26.0, 18.0, 15], center = true);
            // MTF-01 mounting screw holes
            for (dx = [-mtf01_hole_x/2, mtf01_hole_x/2]) {
                for (dy = [-mtf01_hole_y/2, mtf01_hole_y/2]) {
                    translate([dx, dy, 0]) cylinder(r = 1.1, h = 15, center = true);
                }
            }
        }
        
        // Battery Strap Routing Slots (Dual 20mm Kevlar straps)
        translate([0, 32, 0]) cube([22.0, 3.5, 15], center = true);
        translate([0, -32, 0]) cube([22.0, 3.5, 15], center = true);
        
        // Weight Reduction & Airflow Cutouts (SIMP topology light pockets)
        translate([0, -52, 0]) cylinder(r = 10, h = 15, center = true);
    }
}

// 5. Heavy-Duty Connecting Truss Spiders (Fuselage to Ducts)
module structural_trusses() {
    // Front-Left truss
    hull() {
        translate([0, motor_y_front/2, 0]) cube([fuselage_width - 10, 16, deck_thickness], center = true);
        translate([motor_x_offset - 15, motor_y_front, 0]) cylinder(r = 8, h = deck_thickness, center = true);
    }
    // Front-Right truss
    hull() {
        translate([0, motor_y_front/2, 0]) cube([fuselage_width - 10, 16, deck_thickness], center = true);
        translate([-motor_x_offset + 15, motor_y_front, 0]) cylinder(r = 8, h = deck_thickness, center = true);
    }
    // Rear-Left truss
    hull() {
        translate([0, -motor_y_rear/2, 0]) cube([fuselage_width - 10, 16, deck_thickness], center = true);
        translate([motor_x_offset - 15, -motor_y_rear, 0]) cylinder(r = 8, h = deck_thickness, center = true);
    }
    // Rear-Right truss
    hull() {
        translate([0, -motor_y_rear/2, 0]) cube([fuselage_width - 10, 16, deck_thickness], center = true);
        translate([-motor_x_offset + 15, -motor_y_rear, 0]) cylinder(r = 8, h = deck_thickness, center = true);
    }
    
    // Duct-to-Duct Interlock Bridges (Lateral stiffness)
    translate([motor_x_offset, 0, 0])
        cube([duct_wall_thick * 2 + 2, motor_y_front + motor_y_rear - (duct_outer_radius * 1.6), deck_thickness + 2], center = true);
    translate([-motor_x_offset, 0, 0])
        cube([duct_wall_thick * 2 + 2, motor_y_front + motor_y_rear - (duct_outer_radius * 1.6), deck_thickness + 2], center = true);
}

// 6. Front Camera Casing & Tilt-Adjustable Cradle (Raspberry Pi Global Shutter Cam)
module front_camera_cage() {
    translate([0, fuselage_length/2 - 5, 10]) {
        difference() {
            cube([36.0, 24.0, 26.0], center = true);
            // Interior hollow for Global Shutter Camera
            cube([30.0, 28.0, 22.0], center = true);
            // Front lens aperture
            rotate([90, 0, 0]) cylinder(r = 9.5, h = 30, center = true);
            // Tilt pivot mounting screw holes (M2)
            rotate([0, 90, 0]) cylinder(r = 1.1, h = 40, center = true);
        }
    }
}

// 7. Top LiDAR Elevated Deck (Unobstructed 360° Horizontal Laser Line)
module top_lidar_tower() {
    translate([0, 0, lidar_riser_height]) {
        difference() {
            // Platform
            cylinder(r = 24.0, h = 2.8, center = true);
            // Center cable pass-through hole
            cylinder(r = 7.0, h = 10, center = true);
            // 4x M2.5 mounting holes for LD19 / RPLIDAR C1
            for (a = [45, 135, 225, 315]) {
                rotate([0, 0, a])
                    translate([lidar_mount_spacing / sqrt(2), 0, 0])
                    cylinder(r = 1.4, h = 10, center = true);
            }
        }
        // 4x Standoff riser legs connecting to central fuselage
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([20.0, 0, -lidar_riser_height / 2])
                cylinder(r = 3.0, h = lidar_riser_height, center = true);
        }
    }
}

// 8. Bottom TPU Landing Skid & Ground Standoffs (15mm Ground Clearance)
module landing_skids() {
    for (dx = [-motor_x_offset, motor_x_offset]) {
        for (dy = [-motor_y_rear, motor_y_front]) {
            translate([dx, dy, -duct_height/2 - 6]) {
                cylinder(r = 6.0, h = 12.0, center = true);
            }
        }
    }
}

// ==============================================================================
// COMPLETE MONOLITHIC UNIBODY CINEWHOOP ASSEMBLY
// ==============================================================================
module nidar_airmouse_unibody_frame() {
    color([0.2, 0.2, 0.25]) { // PETG-CF matte carbon grey
        union() {
            // Central Deck & Structural Trusses
            central_fuselage();
            structural_trusses();
            
            // 4x Ducted Nacelles with Prop Guards
            ducted_motor_corner( motor_x_offset,  motor_y_front); // Front Right
            ducted_motor_corner(-motor_x_offset,  motor_y_front); // Front Left
            ducted_motor_corner( motor_x_offset, -motor_y_rear);  // Rear Right
            ducted_motor_corner(-motor_x_offset, -motor_y_rear);  // Rear Left
            
            // Integrated Front Camera Cage
            front_camera_cage();
            
            // Elevated 360° LiDAR Platform
            top_lidar_tower();
        }
    }
    
    // TPU Landing Skids & Vibration Dampers (Cyan)
    color([0.0, 0.7, 0.85, 0.9]) {
        landing_skids();
    }
}

// Render the complete frame
nidar_airmouse_unibody_frame();
