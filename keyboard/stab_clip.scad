// ---------------------------------------------------------------
// Space-bar stabilizer clip — Apple II clone keyboard
//
// ---------------------------------------------------------------

// ---- overall -------------------------------------------------
top_width     = 8.0;    // [measured] front-back width of body/post/hook
leg_top_width = 5.0;    // [measured] front-back width of legs (centered)
body_length   = 14.0;   // [measured] long edge sitting on the plate
body_height   = 2.0;    // thickness of body bar (profile height)
chamfer_left  = 0.8;    // 45-deg chamfer on top corners of the body,
chamfer_right = 0.8;    //   as seen in side_close.jpg; 0 = square

// ---- post (front stop for the wire, left of the hook) --------
post_x      = 7.2;      // left edge of post, from left end of body
post_width  = 1.4;
post_height = 3.2;      // [measured] visible vertical part above body

// ---- hook (retains the stab wire; opens down/left) -----------
hook_riser_x     = 12.0; // left edge of vertical riser
hook_riser_width = 1.2;
hook_height      = 3.0;  // top of hook above top of body
hook_arm         = 1;  // thickness of horizontal top arm
hook_lip_width   = 0.6;  // width of the down-turned lip at arm's end
hook_lip_depth   = 0.8;  // how far the lip hangs below the arm
wire_slot        = 1.3;  // channel for the wire: lip <-> riser
                         //   = wire diameter + ~0.1..0.2 clearance

// ---- snap legs (press into baseplate slots) ------------------
leg_width       = 1.4;
plate_thickness = 1.2;  // baseplate sheet thickness: barb catches
                        //   this far below the body underside
barb_depth      = 0.5;  // how far the barb flares past the leg side
barb_length     = 0.8;  // vertical run of the barb ramp below the catch
tip_taper       = 1.0;  // tapered spike tip, eases insertion

leg1_x      = 3.5;      // left edge of left leg
leg1_length = 6.25;     // [measured] body underside to tip
leg1_barb   = -.8;       // barb side: -1 = flares left, +1 = right

leg2_x      = 9.4;      // left edge of right leg
leg2_length = 6.25;     // [measured]
leg2_barb   = .8;

// ---- preview helpers -----------------------------------------
show_plate = true;      // ghost of the baseplate, to judge barb catch

// ===============================================================

body_top = body_height;

// entry gap the wire passes through, between post and hook lip
entry_gap = (hook_riser_x - wire_slot - hook_lip_width) - (post_x + post_width);
echo(str("wire entry gap (post to hook lip): ", entry_gap, " mm"));

// body bar with 45-deg chamfers on its top corners
module body2d() {
    polygon([
        [0, 0],
        [body_length, 0],
        [body_length, body_height - chamfer_right],
        [body_length - chamfer_right, body_height],
        [chamfer_left, body_height],
        [0, body_height - chamfer_left]
    ]);
}

module post2d() {
    translate([post_x, 0])
        square([post_width, body_top + post_height]);
}

module hook2d() {
    arm_left = hook_riser_x - wire_slot - hook_lip_width;
    // vertical riser
    translate([hook_riser_x, 0])
        square([hook_riser_width, body_top + hook_height]);
    // horizontal top arm, reaching left over the wire channel
    translate([arm_left, body_top + hook_height - hook_arm])
        square([hook_riser_x + hook_riser_width - arm_left, hook_arm]);
    // down-turned lip at the arm's left end
    translate([arm_left, body_top + hook_height - hook_arm - hook_lip_depth])
        square([hook_lip_width, hook_lip_depth]);
}

// Snap leg: straight shank through the plate, barbed catch below it,
// tapered spike tip. Catch face is slightly ramped so the clip can be
// levered back out without snapping (unlike the original...).
module leg2d(x, len, barb_side) {
    w = leg_width;
    cx = x + w / 2;                 // mirror axis for barb side
    pts = [
        [x,           0],
        [x + w,       0],
        [x + w,      -(len - tip_taper)],
        [cx,         -len],                                  // tip
        [x - barb_depth, -(plate_thickness + barb_length)],  // barb peak
        [x,          -plate_thickness]                       // catch
    ];
    // points above are for a left-flaring barb; mirror for right
    polygon(barb_side < 0 ? pts : [for (p = pts) [2 * cx - p[0], p[1]]]);
}

// everything above the plate: full 8 mm front-back width
module top_profile2d() {
    union() {
        body2d();
        post2d();
        hook2d();
    }
}

// snap legs: narrower, run through the plate slots
module legs2d() {
    leg2d(leg1_x, leg1_length, leg1_barb);
    leg2d(leg2_x, leg2_length, leg2_barb);
}

// ---- 3D part --------------------------------------------------
linear_extrude(height = top_width)
    top_profile2d();

// legs centered front-back under the body, overlapping slightly
// into the body so the union is watertight
translate([0, 0, (top_width - leg_top_width) / 2])
    linear_extrude(height = leg_top_width)
        union() {
            legs2d();
            translate([0, 0])
                square([body_length, body_height]);  // fuse into body
        }

// ghost baseplate under the body (preview only, not exported)
if (show_plate)
    %translate([-3, -plate_thickness, -2])
        cube([body_length + 6, plate_thickness, top_width + 4]);
