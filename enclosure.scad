// SPDX-License-Identifier: MIT
$fa = 1;
$fs = 0.4;

include <lib/pins.scad> // pins library from Tony Buser (https://github.com/tbuser)

case_length = 135;
case_width = 100;
case_height = 50;

battery_length = 47;
battery_width = 73;
battery_height = 10;

show_all = true;
show_battery = false;
show_base = false;
show_top = false;

if (show_all == true) {
    translate([50, 0, 0])
        enclosure_base();
    translate([-50, 0, 0])
        battery_pocket();
    translate([200, 0, 0])
        enclosure_top();
}

if (show_battery == true) {
    battery_pocket();
}

if (show_base == true) {
    enclosure_base();
}

if (show_top == true) {
    enclosure_top();
}



module enclosure_base() {
    difference() {
        cube([case_length + 1, case_width + 1, (case_height)], center=true);
        translate([0, 0, 6])
            cube([(case_length - 1.5), (case_width - 1.5), (case_height + 1)], center=true);

        // Pinholes for the battery pocket mounting pins
        translate([(-case_length / 2) + 70.5, (-case_width / 2) + 28.5, (-case_height / 2) + 0.5])
            pinhole(r=2, h=5); // from top; uppper left pinhole
        translate([(case_length / 2) - 12.5, (-case_width / 2) + 28.5, (-case_height / 2) + 0.5])
            pinhole(r=2, h=5); // from top; bottom left pinhole
        translate([(-case_length / 2) + 70.5, (case_width / 2) - 28.5, (-case_height / 2) + 0.5])
            pinhole(r=2, h=5); // from top; upper right pinhole
        translate([(case_length / 2) - 12.5, (case_width / 2) - 28.5, (-case_height / 2) + 0.5])
            pinhole(r=2, h=5); // from top; bottom right pinhole

        // Opening for rotary encoder
        rotate([90, 0, 0])
            translate([ (case_width / 2) - 40 , (case_height / 2) - 24, (case_length / 2) - 19 ])
                cylinder(d=6.90, h=2);

        // mounting holes for rotary encoder
        // x is case_width, z is case_length, y is case_height,
        rotate([90, 0, 0])  // looking at rotary encoder - top left mounting hole
            translate([(case_width / 2) - 29.75,  (case_height / 2) - 13.75, (case_length / 2) - 19])
                cylinder(d=3, h=2);
        rotate([90, 0, 0])  // looking at rotary encoder - bottom left mounting hole
            translate([(case_width / 2) - 29.75,  (-case_height / 2) + 15.75, (case_length / 2) - 19])
                cylinder(d=3, h=2);
        rotate([90, 0, 0])  // looking at rotary encoder - top right mounting hole
            translate([(case_width / 2) - 50.25,   (case_height / 2) - 13.75, (case_length / 2) - 19])
                cylinder(d=3, h=2);
        rotate([90, 0, 0])  // looking at rotary encoder - bottom right mounting hole
            translate([(case_width / 2) - 50.25,  (-case_height / 2) + 15.75, (case_length / 2) - 19])
                cylinder(d=3, h=2);

        // Headphone/speaker Jack
        rotate([90, 0, 0])
            translate([(case_length / 2) - 25, (case_height / 2) - 31, (case_width / 2) - 1])
                cylinder(d=6.35, h=2);

        // Opening for the slider switch
        translate([(case_length / 2) - 25, (-case_width / 2) , (case_height / 2) - 20])
            cube([10, 2, 4], center=true);

        // Opening for usb charging plug
        translate([(case_length / 2) - 1, (-case_width / 2) + 32.5, (case_height / 2) - 11])
            cube([2, 11.2, 6.12]);

        // bottom venting
        translate([(case_length / 2) - 50, (-case_width / 2) + 38, (-case_height / 2) - 3])
            bottom_vent();
        translate([(case_length / 2) - 50, (-case_width / 2) + 48, (-case_height / 2) - 3])
            bottom_vent();
        translate([(case_length / 2) - 50, (-case_width / 2) + 58, (-case_height / 2) - 3])
            bottom_vent();

        // side vent
        translate([(-case_length / 2) - 5, 0, 0])
            side_vent();
    }


    // The pinholes where the top will connect
    translate([(case_length / 2) - 4 - 0.001, (case_width / 2) - 4 - 0.001, (-case_height / 2)  + 25 - 0.001])
        base_top_pinholes();
    translate([(-case_length / 2) + 4 - 0.001, (case_width / 2) - 4 - 0.001, (-case_height / 2) + 25 - 0.001])
        base_top_pinholes();
    translate([(case_length / 2) - 4 - 0.001, (-case_width / 2) + 4 - 0.001, (-case_height / 2) + 25 - 0.001])
        base_top_pinholes();
    translate([(-case_length / 2) + 4 - 0.001, (-case_width / 2) + 4 - 0.001, (-case_height / 2) + 25 - 0.001])
        base_top_pinholes();

}

// A slot to hold the battery so it doesn't rattle around in the enclosure
// the pocket will snap into the main part of the case and will have mounting holes for the doubler board
module battery_pocket() {
    difference() {
       cube([(battery_length + 1), (battery_width + 1), battery_height], center=true);
        translate([0, 0, 1])
            cube([(battery_length - 1), (battery_width - 1), (battery_height) - 2], center = true);
        // mounting holes for the doubler
        translate([(-battery_length / 2) + 2.5, (-battery_width / 2) + 24.25, (-battery_height / 2) - 2])
            cylinder(d=3, h=5);
        translate([(battery_length / 2) - 2.5, (-battery_width / 2) + 24.25, (-battery_height / 2) - 2])
            cylinder(d=3, h=5);
        translate([(-battery_length / 2) + 2.5, (battery_width / 2) - 3, (-battery_height / 2) - 2])
            cylinder(d=3, h=5);
        translate([(battery_length / 2) - 2.5, (battery_width / 2) - 3, (-battery_height / 2) - 2])
            cylinder(d=3, h=5);

        // mounting holes for amp
        translate([(-battery_width / 2) + 18, (-battery_length / 2) - 10, (-battery_height / 2) - 2])
            cylinder(d=3, h=5);
        translate([(-battery_width / 2) + 31, (-battery_length / 2) - 10, (-battery_height / 2) - 2])
            cylinder(d=3, h=5);

        // cut out for battery cable
        translate([(-battery_length / 2), (battery_width / 2) - 3.5, 2.5])
            cube([2, 6, 6], center=true);
    }


    // Supports and Pins for attaching to main case
    translate([(-battery_length / 2) + 2.75 - 0.001, (-battery_width / 2) + 10.5 - 0.001, (-battery_height / 2) + 5 - 0.001])
        cube([4.5, 6, battery_height], center=true);
        translate([(-battery_length /2) + 2 - 0.001, (-battery_width / 2) + 10.5 - 0.001, (battery_height / 2) - 0.001])
            pin(r=2, h=5);
    translate([(battery_length / 2) - 2.75 - 0.001, (-battery_width / 2) + 10.5 - 0.001, (-battery_height / 2) + 5 - 0.001])
        cube([4.5, 6, battery_height], center=true);
            translate([(battery_length / 2) - 2 - 0.001, (-battery_width / 2) + 10.5, (battery_height / 2) - 0.001])
            pin(r=2, h=5);
    translate([(-battery_length / 2) + 2.75 - 0.001, (battery_width / 2) - 10.5, (-battery_height / 2) + 5 - 0.001])
        cube([4.5, 6, battery_height], center=true);
        translate([(-battery_length /2) + 2 - 0.001, (battery_width / 2) - 10.5, (battery_height / 2) + - 0.001])
            pin(r=2, h=5);
    translate([(battery_length / 2) - 2.75 - 0.001, (battery_width / 2) - 10.5, (-battery_height / 2) + 5 - 0.001])
        cube([4.5, 6, battery_height], center=true);
        translate([(battery_length /2) - 2 - 0.001, (battery_width / 2) - 10.5, (battery_height / 2) + - 0.001])
        pin(r=2, h=5);

    // Support to stop battery from moving fore and aft
    translate([10, (-battery_width / 2) + 3, (-battery_height / 2) + 5 - 0.001])
        cube([5, 5, battery_height], center=true);
}

module base_top_pinholes() {
    difference() {
        cube([8, 8, (case_height)], center=true);
        translate([0, 0, (case_height / 2) - 8])
            pinhole(r=3, h=9);
    }
}


module enclosure_top() {
   difference() {
       cube([case_length + 1, case_width + 1, 6], center=true);
       translate([0, 0, 1])
            cube([(case_length - 1), (case_width - 1), 7], center=true);

       // hole for the display
       translate([(case_width / 2) - 18, (-case_length / 2) + 55, -3])
           cube([35.56, 45, 2], center=true);

       // display mounting points
       translate([(case_length / 2) - 50.75, (-case_width / 2) + 11.25, -4])
           cylinder(d=3, h=2);
       translate([(case_length / 2) - 20.25, (-case_width / 2) + 11.25, -4])
           cylinder(d=3, h=2);

       // cut out for the Kailh key
       translate([(-case_width / 2) , (case_length / 4) - 22, -3])
           cube([15, 15, 2], center=true);

       // slot for SD card extender
       translate([(case_width / 2) - 18, (-case_length / 2) + 18, 2.25])
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
    cube([8, 8, 5], center=true);
    translate([0, -0.25, 2 - 0.001])
        pin(r=3, h=8);
}

module top_pins_right() {
    cube([8, 8, 5], center=true);
    translate([0, 0.25, 2 - 0.001])
        pin(r=3, h=8);
}

module bottom_vent() {
    minkowski() {
        cube([battery_length / 2 + 4, 3, 10]);
        cylinder(1);
    }
}

module side_vent() {
    rotate([180, 90, 0])
    scale([1, 1, 0.1])
        surface(file = "images/dotted_circle.png", center = true, invert = true);
}

