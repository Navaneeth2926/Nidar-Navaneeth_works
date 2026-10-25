"""
==============================================================================
NIDAR AirMouse - Autodesk Fusion 360 Frame Generation Script
Target: 3.5" Ducted Unibody Cinewhoop (PETG-CF / SIMP Optimized Geometry)
Meets NIDAR Rules: Width <= 26cm (outer width 23.6cm), fits 2ft x 2ft launch box.
Integrates: Matek H743-WLITE, Raspberry Pi 5 + AI HAT+, 360 LiDAR, Optical Flow.
==============================================================================
How to run in Autodesk Fusion 360:
1. Open Autodesk Fusion 360.
2. Go to "UTILITIES" tab -> Click "Scripts and Add-Ins" (or press Shift + S).
3. Under "My Scripts", click the Green "+" icon or "Create".
4. Choose "Python", name it "NidarAirMouseFrame", and paste this code.
5. Click "Run". The full 3D solid model will generate automatically!
==============================================================================
"""

"""
==============================================================================
NIDAR AirMouse - Autodesk Fusion 360 Frame, Propulsion & Landing System
Target: 3.5" Ducted Metal Hybrid Cinewhoop (Aerospace Aluminum 7075 / Ti)
Complies with NIDAR 2026-27 Rules:
- Outer Width: 22.1 cm (<= 26 cm corridor rule compliant)
- Fits inside 2ft x 2ft (60.9 cm x 60.9 cm) launch area
Components Integrated:
- Airframe: Lightweight Aerospace Aluminum Unibody with 360 Continuous Ducts
- Motors: 4x EMAX ECO II 2004 3000KV Brushless Motors (Dia 24.7mm x H 13.2mm)
- Propellers: 4x Gemfan D90-3 (3.5" / 90mm) 3-Blade Ducted Propellers
- Landing Gear: 4x Sturdy 18mm Ground-Clearance Landing Skids with Foot Pads
- Electronics Stacks: Matek H743-WLITE (30.5x30.5), Pi 5 (58x49), MTF-01 Flow
==============================================================================
How to run in Autodesk Fusion 360:
1. Open Autodesk Fusion 360.
2. Go to "UTILITIES" tab -> Click "Scripts and Add-Ins" (or press Shift + S).
3. Under "My Scripts", select or create "NidarAirMouseFrame", click "Edit".
4. Paste this complete code, save (Ctrl + S), and click "Run".
==============================================================================
"""

import math
import traceback

try:
    import adsk.core
    import adsk.fusion
    IN_FUSION = True
except ImportError:
    IN_FUSION = False


def apply_appearance(body, app, appearance_name):
    """Safely apply a material appearance from Fusion 360's built-in library."""
    try:
        mat_lib = app.materialLibraries.itemByName("Fusion 360 Appearance Library")
        if mat_lib:
            app_match = mat_lib.appearances.itemByName(appearance_name)
            if app_match:
                body.appearance = app_match
    except:
        pass


def run(context):
    ui = None
    try:
        app = adsk.core.Application.get()
        ui = app.userInterface
        doc = app.documents.add(adsk.core.DocumentTypes.FusionDesignDocumentType)
        design = app.activeProduct

        rootComp = design.rootComponent
        features = rootComp.features
        sketches = rootComp.sketches
        xyPlane = rootComp.xYConstructionPlane

        # =====================================================================
        # SPECIFICATIONS & DIMENSIONS (All internal Fusion units in cm)
        # =====================================================================
        # 1. Airframe Dimensions (Aerospace Aluminum 7075-T6)
        deck_t = 0.30  # 3.0 mm rigid aluminum deck plate
        fuselage_w = 6.8  # 68 mm width
        fuselage_l = 14.6 # 146 mm length

        # 2. Propeller Dimensions: Gemfan D90-3 (3.5" / 90mm 3-Blade)
        prop_dia_cm = 3.5 * 2.54  # 8.89 cm (90 mm diameter)
        prop_radius = prop_dia_cm / 2.0  # 4.445 cm
        blade_clearance = 0.205  # 2.05 mm blade tip gap
        duct_inner_r = prop_radius + blade_clearance  # 4.65 cm (93 mm ID)
        duct_wall_t = 0.22  # 2.2 mm duct wall
        duct_outer_r = duct_inner_r + duct_wall_t  # 4.87 cm (97.4 mm OD)
        duct_h = 2.60  # 26.0 mm shroud height

        # 3. Motor Offsets (Squished-X Deadcat layout)
        motor_x = 6.20  # cm
        motor_y_front = 5.80  # cm
        motor_y_rear = 5.80  # cm
        motor_positions = [
            (motor_x, motor_y_front, "Front_Right"),
            (-motor_x, motor_y_front, "Front_Left"),
            (motor_x, -motor_y_rear, "Rear_Right"),
            (-motor_x, -motor_y_rear, "Rear_Left")
        ]

        # 4. Motor Specs: EMAX ECO II 2004 3000KV
        motor_bell_r = 1.235  # 24.7 mm outer diameter
        motor_base_h = 0.35   # 3.5 mm base height
        motor_bell_h = 0.95   # 9.5 mm bell rotor height
        motor_shaft_r = 0.25  # 5.0 mm propeller shaft
        motor_shaft_h = 0.50  # 5.0 mm shaft height above bell

        # 5. Landing Gear Specs: 18mm ground clearance
        leg_height = 1.80     # 18.0 mm downward height
        leg_radius = 0.45     # 9.0 mm leg strut diameter
        foot_radius = 0.85    # 17.0 mm foot pad diameter
        foot_height = 0.30    # 3.0 mm foot pad thickness

        # =====================================================================
        # 1. CENTRAL FUSELAGE DECK (METAL BASE)
        # =====================================================================
        fuselageSketch = sketches.add(xyPlane)
        f_lines = fuselageSketch.sketchCurves.sketchLines
        f_lines.addTwoPointRectangle(
            adsk.core.Point3D.create(-fuselage_w / 2.0, -fuselage_l / 2.0, 0),
            adsk.core.Point3D.create(fuselage_w / 2.0, fuselage_l / 2.0, 0)
        )
        prof_fuse = fuselageSketch.profiles.item(0)
        ext_fuse = features.extrudeFeatures.addSimple(
            prof_fuse,
            adsk.core.ValueInput.createByReal(deck_t),
            adsk.fusion.FeatureOperations.NewBodyFeatureOperation
        )
        frame_body = ext_fuse.bodies.item(0)
        frame_body.name = "Metal_Fuselage_Chassis"
        apply_appearance(frame_body, app, "Aluminum - Anodized Glossy (Grey)")

        # =====================================================================
        # 2. DUCTED SHROUDS & CONNECTING STRUTS (360 PROP GUARDS)
        # =====================================================================
        for mx, my, name in motor_positions:
            # Duct Shroud
            ductSketch = sketches.add(xyPlane)
            d_circles = ductSketch.sketchCurves.sketchCircles
            d_circles.addByCenterRadius(adsk.core.Point3D.create(mx, my, 0), duct_outer_r)
            d_circles.addByCenterRadius(adsk.core.Point3D.create(mx, my, 0), duct_inner_r)

            prof_annulus = None
            for p in ductSketch.profiles:
                if p.profileLoops.count == 2:
                    prof_annulus = p
                    break

            if prof_annulus:
                features.extrudeFeatures.addSimple(
                    prof_annulus,
                    adsk.core.ValueInput.createByReal(duct_h),
                    adsk.fusion.FeatureOperations.JoinFeatureOperation
                )

            # Motor Mounting Pod Hub
            hubSketch = sketches.add(xyPlane)
            hubSketch.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(mx, my, 0), 1.0
            )  # 20mm dia hub plate
            features.extrudeFeatures.addSimple(
                hubSketch.profiles.item(0),
                adsk.core.ValueInput.createByReal(deck_t),
                adsk.fusion.FeatureOperations.JoinFeatureOperation
            )

            # Connecting Arm Truss from Fuselage to Motor Pod
            armSketch = sketches.add(xyPlane)
            y_base = my * 0.55
            armSketch.sketchCurves.sketchLines.addTwoPointRectangle(
                adsk.core.Point3D.create(0, y_base - 0.75, 0),
                adsk.core.Point3D.create(mx, my + 0.75, 0)
            )
            if armSketch.profiles.count > 0:
                features.extrudeFeatures.addSimple(
                    armSketch.profiles.item(0),
                    adsk.core.ValueInput.createByReal(deck_t),
                    adsk.fusion.FeatureOperations.JoinFeatureOperation
                )

            # Stator Aerodynamic Ribs (3 struts inside duct)
            for angle_deg in [30, 150, 270]:
                rad = math.radians(angle_deg)
                sx = mx + (duct_inner_r / 2.0) * math.cos(rad)
                sy = my + (duct_inner_r / 2.0) * math.sin(rad)
                strutSketch = sketches.add(xyPlane)
                strutSketch.sketchCurves.sketchCircles.addByCenterRadius(
                    adsk.core.Point3D.create(sx, sy, 0), 0.25
                )
                if strutSketch.profiles.count > 0:
                    features.extrudeFeatures.addSimple(
                        strutSketch.profiles.item(0),
                        adsk.core.ValueInput.createByReal(deck_t),
                        adsk.fusion.FeatureOperations.JoinFeatureOperation
                    )

        # =====================================================================
        # 3. FOUR LANDING LEGS (18mm GROUND CLEARANCE)
        # =====================================================================
        for mx, my, name in motor_positions:
            # Landing Strut (Extruded downward from z=0 to z=-leg_height)
            legSketch = sketches.add(xyPlane)
            # Offset leg slightly outward for wide landing stance
            leg_offset_x = mx + (0.8 if mx > 0 else -0.8)
            leg_offset_y = my + (0.8 if my > 0 else -0.8)

            legSketch.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(leg_offset_x, leg_offset_y, 0), leg_radius
            )
            prof_leg = legSketch.profiles.item(0)
            ext_leg = features.extrudeFeatures.addSimple(
                prof_leg,
                adsk.core.ValueInput.createByReal(-leg_height),
                adsk.fusion.FeatureOperations.NewBodyFeatureOperation
            )
            leg_body = ext_leg.bodies.item(0)
            leg_body.name = f"Landing_Leg_{name}"
            apply_appearance(leg_body, app, "Aluminum - Satin")

            # Stable Landing Foot Pad at bottom
            footSketch = sketches.add(xyPlane)
            footSketch.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(leg_offset_x, leg_offset_y, 0), foot_radius
            )
            prof_foot = footSketch.profiles.item(0)

            # Create an offset construction plane for the foot pad
            planeInput = rootComp.constructionPlanes.createInput()
            planeInput.setByOffset(xyPlane, adsk.core.ValueInput.createByReal(-leg_height))
            footPlane = rootComp.constructionPlanes.add(planeInput)

            footSketchBottom = sketches.add(footPlane)
            footSketchBottom.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(leg_offset_x, leg_offset_y, 0), foot_radius
            )
            prof_foot_bottom = footSketchBottom.profiles.item(0)
            features.extrudeFeatures.addSimple(
                prof_foot_bottom,
                adsk.core.ValueInput.createByReal(-foot_height),
                adsk.fusion.FeatureOperations.JoinFeatureOperation
            )

        # =====================================================================
        # 4. FOUR EMAX ECO II 2004 3000KV BRUSHLESS MOTORS
        # =====================================================================
        for mx, my, name in motor_positions:
            # Motor Base (Stationary Stator Mount)
            motorBaseSketch = sketches.add(xyPlane)
            motorBaseSketch.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(mx, my, 0), 1.15
            )
            # Offset to sit on top of the deck plate
            planeInputBase = rootComp.constructionPlanes.createInput()
            planeInputBase.setByOffset(xyPlane, adsk.core.ValueInput.createByReal(deck_t))
            motorBasePlane = rootComp.constructionPlanes.add(planeInputBase)

            mBaseSketch = sketches.add(motorBasePlane)
            mBaseSketch.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(mx, my, 0), 1.10
            )
            ext_mbase = features.extrudeFeatures.addSimple(
                mBaseSketch.profiles.item(0),
                adsk.core.ValueInput.createByReal(motor_base_h),
                adsk.fusion.FeatureOperations.NewBodyFeatureOperation
            )
            mbase_body = ext_mbase.bodies.item(0)
            mbase_body.name = f"Motor_Base_{name}"
            apply_appearance(mbase_body, app, "Steel - Satin")

            # Motor Rotor Bell (Anodized Metal Bell Housing)
            planeInputBell = rootComp.constructionPlanes.createInput()
            planeInputBell.setByOffset(xyPlane, adsk.core.ValueInput.createByReal(deck_t + motor_base_h))
            motorBellPlane = rootComp.constructionPlanes.add(planeInputBell)

            mBellSketch = sketches.add(motorBellPlane)
            mBellSketch.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(mx, my, 0), motor_bell_r
            )
            ext_mbell = features.extrudeFeatures.addSimple(
                mBellSketch.profiles.item(0),
                adsk.core.ValueInput.createByReal(motor_bell_h),
                adsk.fusion.FeatureOperations.NewBodyFeatureOperation
            )
            mbell_body = ext_mbell.bodies.item(0)
            mbell_body.name = f"EMAX_ECO_II_2004_{name}"
            apply_appearance(mbell_body, app, "Aluminum - Polished")

            # Propeller Shaft (5mm / 0.25cm radius)
            planeInputShaft = rootComp.constructionPlanes.createInput()
            planeInputShaft.setByOffset(xyPlane, adsk.core.ValueInput.createByReal(deck_t + motor_base_h + motor_bell_h))
            motorShaftPlane = rootComp.constructionPlanes.add(planeInputShaft)

            mShaftSketch = sketches.add(motorShaftPlane)
            mShaftSketch.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(mx, my, 0), motor_shaft_r
            )
            ext_mshaft = features.extrudeFeatures.addSimple(
                mShaftSketch.profiles.item(0),
                adsk.core.ValueInput.createByReal(motor_shaft_h),
                adsk.fusion.FeatureOperations.JoinFeatureOperation
            )

        # =====================================================================
        # 5. FOUR GEMFAN D90-3 (3.5" TRI-BLADE) DUCTED PROPELLERS
        # =====================================================================
        prop_z_plane = deck_t + motor_base_h + motor_bell_h + 0.10

        planeInputProp = rootComp.constructionPlanes.createInput()
        planeInputProp.setByOffset(xyPlane, adsk.core.ValueInput.createByReal(prop_z_plane))
        propPlane = rootComp.constructionPlanes.add(planeInputProp)

        for mx, my, name in motor_positions:
            propSketch = sketches.add(propPlane)

            # Central Propeller Hub (12mm dia)
            propSketch.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(mx, my, 0), 0.60
            )

            # 3 Aerodynamic Blades spaced at 120 degrees
            for blade_i in range(3):
                angle = blade_i * (2.0 * math.pi / 3.0) + (math.pi / 6.0)
                # Blade tip position (4.40 cm from motor center)
                tip_r = prop_radius - 0.05
                tip_x = mx + tip_r * math.cos(angle)
                tip_y = my + tip_r * math.sin(angle)

                # Tangent vector for chord width
                perp_x = -math.sin(angle) * 0.40
                perp_y = math.cos(angle) * 0.40

                hub_x = mx + 0.55 * math.cos(angle)
                hub_y = my + 0.55 * math.sin(angle)

                p1 = adsk.core.Point3D.create(hub_x + perp_x * 0.8, hub_y + perp_y * 0.8, 0)
                p2 = adsk.core.Point3D.create(tip_x + perp_x * 0.4, tip_y + perp_y * 0.4, 0)
                p3 = adsk.core.Point3D.create(tip_x - perp_x * 0.4, tip_y - perp_y * 0.4, 0)
                p4 = adsk.core.Point3D.create(hub_x - perp_x * 0.8, hub_y - perp_y * 0.8, 0)

                propSketch.sketchCurves.sketchLines.addByTwoPoints(p1, p2)
                propSketch.sketchCurves.sketchLines.addByTwoPoints(p2, p3)
                propSketch.sketchCurves.sketchLines.addByTwoPoints(p3, p4)
                propSketch.sketchCurves.sketchLines.addByTwoPoints(p4, p1)

            # Extrude all profiles of the 3-blade propeller
            for prof in propSketch.profiles:
                try:
                    ext_prop = features.extrudeFeatures.addSimple(
                        prof,
                        adsk.core.ValueInput.createByReal(0.25),
                        adsk.fusion.FeatureOperations.NewBodyFeatureOperation
                    )
                    prop_body = ext_prop.bodies.item(0)
                    prop_body.name = f"Gemfan_D90_Propeller_{name}"
                    apply_appearance(prop_body, app, "Plastic - Matte (Cyan)")
                except:
                    pass

        # =====================================================================
        # 6. MOUNTING HOLES (FC, PI 5, OPTICAL FLOW & MOTOR BOLTS)
        # =====================================================================
        cutoutSketch = sketches.add(xyPlane)
        c_circles = cutoutSketch.sketchCurves.sketchCircles

        # Flight Controller: Matek H743-WLITE (30.5 x 30.5 mm M3)
        fc_spacing = 3.05
        for sx in [-fc_spacing / 2.0, fc_spacing / 2.0]:
            for sy in [-fc_spacing / 2.0, fc_spacing / 2.0]:
                c_circles.addByCenterRadius(adsk.core.Point3D.create(sx, sy, 0), 0.16)

        # Raspberry Pi 5 + AI HAT+ (58.0 x 49.0 mm M2.5)
        pi_x = 4.90 / 2.0
        pi_y = 5.80 / 2.0
        for px in [-pi_x, pi_x]:
            for py in [-pi_y, py_y]:
                c_circles.addByCenterRadius(adsk.core.Point3D.create(px, py, 0), 0.13)

        # MicoAir MTF-01 Optical Flow / ToF Center Window (26mm x 18mm)
        cutoutSketch.sketchCurves.sketchLines.addTwoPointRectangle(
            adsk.core.Point3D.create(-1.30, -0.90, 0),
            adsk.core.Point3D.create(1.30, 0.90, 0)
        )

        # Motor Mounting Holes: 12x12mm M2 Pattern
        for mx, my, _ in motor_positions:
            for dx in [-0.60, 0.60]:
                for dy in [-0.60, 0.60]:
                    c_circles.addByCenterRadius(adsk.core.Point3D.create(mx + dx, my + dy, 0), 0.11)

        # Execute Extrude Cut on all cutouts
        for prof in cutoutSketch.profiles:
            try:
                features.extrudeFeatures.addSimple(
                    prof,
                    adsk.core.ValueInput.createByReal(-1.0),
                    adsk.fusion.FeatureOperations.CutFeatureOperation
                )
            except:
                pass

        # Final Notification
        ui.messageBox(
            "NIDAR AirMouse Complete 3D Assembly Generated!\n\n"
            "- Airframe: Aerospace Aluminum 7075-T6 Metal Chassis with 360 Propeller Ducts\n"
            "- Outer Width: 22.1 cm (Rule Compliant <= 26 cm)\n"
            "- Propulsion: 4x EMAX ECO II 2004 3000KV Brushless Motors\n"
            "- Propellers: 4x Gemfan D90-3 (3.5\" Tri-Blade) Ducted Propellers\n"
            "- Landing Gear: 4x Ground-Clearance Landing Skids (18 mm height)\n"
            "- Sensor Integration: Matek H743, Pi 5, & MTF-01 Flow Cutouts"
        )

    except:
        if ui:
            ui.messageBox('Failed:\n{}'.format(traceback.format_exc()))


if __name__ == '__main__':
    if IN_FUSION:
        run(None)
    else:
        print("This script is ready to run directly inside Autodesk Fusion 360 via Scripts and Add-Ins.")

