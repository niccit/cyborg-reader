// SPDX-License-Identifier: MIT
$fa = 1;
$fs = 0.4;

include <lib/pins.scad> // pins library from Tony Buser (https://github.com/tbuser)

case_length = 106.66;
case_width = 68.86;
case_height = 28;

battery_length = 47;
battery_width = 73;
battery_height = 7;

show_all = false;

if (show_all == true) {
    translate([50, 0, 0])
        enclosure_base();
    translate([-50, 0, 0])
        battery_pocket();
    translate([100, 0, 0])
        enclosure_top();
}

// enclosure_base();
// battery_pocket();
enclosure_top();

module enclosure_base() {
    difference() {
        cube([case_length, case_width, (case_height + 6)], center=true);
        translate([0, 0, 6])
            cube([(case_length - 0.5), (case_width - 0.5), (case_height + 1)], center=true);

        // Pinholes for the battery pocket mounting pins
        translate([(-case_length / 2) + 31.25, (-case_width / 2) + 8.75, (-case_height / 2) + 0.5])
            pinhole(r=2, h=5);
        translate([(case_length / 2) - 8, (-case_width / 2) + 8.5, (-case_height / 2) + 0.5])
            pinhole(r=2, h=5);
        translate([(-case_length / 2) + 31.25, (case_width / 2) - 18.25, (-case_height / 2) + 0.5])
            pinhole(r=2, h=5);
        translate([(case_length / 2) - 8, (case_width / 2) - 18.25, (-case_height / 2) + 0.5])
            pinhole(r=2, h=5);

        // Opening for rotary encoder
        rotate([90, 0, 0])
            translate([ (case_width / 4) , (case_height / 2) - 9.5, (-case_length / 3)])
                cylinder(d=6.90, h=2);

        // mounting holes for rotary encoder
        // x is case_width, z is case_length, y is case_height,
        rotate([90, 0, 0])  // looking at rotary encoder - top left mounting hole
            translate([(case_width / 4) + 10.2,  (case_height / 2) + 0.5, (-case_length / 4) - 8])
                cylinder(d=3, h=2);
        rotate([90, 0, 0])  // looking at rotary encoder - bottom left mounting hole
            translate([(case_width / 4) + 10.2,  (-case_height / 8) - 2.25, (-case_length / 4) - 8])
                cylinder(d=3, h=2);
        rotate([90, 0, 0])  // looking at rotary encoder - top right mounting hole
            translate([(-case_width / 4) + 24.2,  (case_height / 2) + 0.5, (-case_length / 4) - 8])
                cylinder(d=3, h=2);
        rotate([90, 0, 0])  // looking at rotary encoder - bottom right mounting hole
            translate([(-case_width / 4) + 24.2,  (-case_height / 8) - 2.25, (-case_length / 4) - 8])
                cylinder(d=3, h=2);

        // Headphone/speaker Jack
        rotate([90, 0, 0])
            translate([(-case_width / 2) + 15, (case_height / 2) - 9.5, (-case_length / 4) - 8])
                cylinder(d=6.35, h=2);

        // Opening for usb charging plug
        translate([(case_length / 2) - 1, (-case_width / 2) + 12.5, (case_height / 2) - 3])
            cube([2, 11.2, 6.12]);

        // Opening for the slider switch
        translate([(case_length / 2), (case_width / 2) - 25, (case_height / 2) - 3])
            cube([2, 10, 4], center=true);
    }


    // The pinholes where the top will connect
    translate([(case_length / 2) - 4 - 0.001, (case_width / 2) - 4 - 0.001, (case_height / 2) - 2])
        base_top_pinholes();
    translate([(-case_length / 2) + 4 - 0.001, (case_width / 2) - 4 - 0.001, (case_height / 2) - 2])
        base_top_pinholes();
    translate([(case_length / 2) - 4 - 0.001, (-case_width / 2) + 4 - 0.001, (case_height / 2) - 2])
        base_top_pinholes();
    translate([(-case_length / 2) + 4 - 0.001, (-case_width / 2) + 4 - 0.001, (case_height / 2) - 2])
        base_top_pinholes();

}

// A slot to hold the battery so it doesn't rattle around in the enclosure
// the pocket will snap into the main part of the case and will have mounting holes for the doubler board
module battery_pocket() {
    difference() {
       cube([(battery_length), (battery_width), battery_height], center=true);
        translate([0, 1, 1])
            cube([(battery_length - 0.5), (battery_width), (battery_height + 1)], center = true);
        // mounting holes for the doubler
        translate([(-battery_length / 2) + 2.5, (-battery_width / 2) + 15, (-battery_height + 1)])
            cylinder(d=3, h=5);
        translate([(battery_length / 2) - 2.5, (-battery_width / 2) + 15, (-battery_height + 1)])
            cylinder(d=3, h=5);
        translate([(-battery_length / 2) + 2.5, (battery_width / 2) - 12.5, (-battery_height + 1)])
            cylinder(d=3, h=5);
        translate([(battery_length / 2) - 2.5, (battery_width / 2) - 12.5, (-battery_height + 1)])
            cylinder(d=3, h=5);

    }

    // Supports and Pins for attaching to main case
    translate([(-battery_length / 2) + 6, (-battery_width / 2) + 3.5, (-battery_height / 2) + 3.5 - 0.001])
        cube([12, 5, battery_height], center=true);
        translate([(-battery_length /2) + 2.5, (-battery_width / 2) + 3.25, (battery_height / 2) + - 0.001])
            pin(r=2, h=5);
    translate([(battery_length / 2) - 6, (-battery_width / 2) + 3.5, (-battery_height / 2) + 3.5 - 0.001])
        cube([12, 5, battery_height], center=true);
        translate([(battery_length /2) - 2.5, (-battery_width / 2) + 3.25, (battery_height / 2) + - 0.001])
            pin(r=2, h=5);
    translate([(-battery_length / 2) + 6, (battery_width / 2) - 2.5, (-battery_height / 2) + 3.5 - 0.001])
        cube([12, 5, battery_height], center=true);
        translate([(-battery_length /2) + 2.5, (battery_width / 2) - 2.5, (battery_height / 2) + - 0.001])
            pin(r=2, h=5);
    translate([(battery_length / 2) - 6, (battery_width / 2) - 2.5, (-battery_height / 2) + 3.5 - 0.001])
        cube([12, 5, battery_height], center=true);
    translate([(battery_length /2) - 2.5, (battery_width / 2) - 2.5, (battery_height / 2) + - 0.001])
        pin(r=2, h=5);

    // This pocket needs to be as wide as the doubler that's attaching to it
    // Need to add stops on the sides so the battery doesn't move around too much
    translate([(-battery_length / 2) + 2 - 0.001, 0, 0])
        cube([4, 5, battery_height], center=true);
    translate([(battery_length / 2) - 2 - 0.001, 0, 0])
        cube([4, 5, battery_height], center=true);
}

module base_top_pinholes() {
    difference() {
        cube([8, 8, 10], center=true);
        translate([0, 0, -4])
            pinhole(r=3, h=9);
    }
}


module enclosure_top() {
   difference() {
       cube([case_length, case_width, 9], center=true);
       translate([0, 0, 1])
            cube([(case_length - 0.5), (case_width - 0.5), 10], center=true);

       // hole for the display
       translate([(case_width / 2) - 10, 0, -4])
           cube([35.56, 45, 2], center=true);

       // display mounting points
       translate([(case_length / 11.75), (-case_width / 2) + 9.75, -5])
           cylinder(d=3, h=2);
       translate([(case_length / 2) - 13.75, (-case_width / 2) + 9.75, -5])
           cylinder(d=3, h=2);

       // slot for SD card extender
       translate([(case_width / 3) + 1.5, (-case_length / 4) - 7.5, 1.25])
           cube([14, 2, 2], center=true);

    }


    translate([(-case_length / 2) + 4 - 0.001, (-case_width / 2) + 4.25 - 0.001, 0.5])
        top_pins_left();
    translate([(-case_length / 2) + 4 - 0.001, (case_width / 2) - 4.25 - 0.001, 0.5])
        top_pins_right();
    translate([(case_length / 2) - 4 - 0.001, (-case_width / 2) + 4.25 - 0.001, 0.5])
        top_pins_left();
    translate([(case_length / 2) - 4 - 0.001, (case_width / 2) - 4.25 - 0.001, 0.5])
        top_pins_right();
}



module top_pins_left() {
    cube([8, 8, 8], center=true);
    translate([0, -0.25, 4 - 0.001])
        pin(r=3, h=8);
}

module top_pins_right() {
    cube([8, 8, 8], center=true);
    translate([0, 0.25, 4 - 0.001])
        pin(r=3, h=8);
}

