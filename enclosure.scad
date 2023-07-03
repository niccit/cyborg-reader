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
        cube([case_length + 3, case_width + 3, (case_height)], center=true);
        translate([0, 0, 7])
            cube([(case_length - 1), (case_width - 1), (case_height + 1)], center=true);

        // Opening for rotary encoder
        rotate([90, 0, 0])
            translate([ (case_width / 2) - 40 , (case_height / 2) - 23, (case_length / 2) - 19 ])
                cylinder(d=6.95, h=5);

        // mounting holes for rotary encoder
        // x is case_width, z is case_length, y is case_height,
        rotate([90, 0, 0])  // looking at rotary encoder - top left mounting hole
            translate([(case_width / 2) - 29.75,  (case_height / 2) - 12.75, (case_length / 2) - 19])
                cylinder(d=3, h=5);
        rotate([90, 0, 0])  // looking at rotary encoder - bottom left mounting hole
            translate([(case_width / 2) - 29.75,  (-case_height / 2) + 16.75, (case_length / 2) - 19])
                cylinder(d=3, h=5);
        rotate([90, 0, 0])  // looking at rotary encoder - top right mounting hole
            translate([(case_width / 2) - 50.25,   (case_height / 2) - 12.75, (case_length / 2) - 19])
                cylinder(d=3, h=5);
        rotate([90, 0, 0])  // looking at rotary encoder - bottom right mounting hole
            translate([(case_width / 2) - 50.25,  (-case_height / 2) + 16.75, (case_length / 2) - 19])
                cylinder(d=3, h=5);

        // Headphone/speaker Jack
        rotate([90, 0, 0])
            translate([(case_length / 2) - 25, (case_height / 2) - 30, (case_width / 2) - 1])
                cylinder(d=6.4, h=5);

        // Opening for the slider switch
        translate([(case_length / 2) - 25, (-case_width / 2) , (case_height / 2) - 19])
            cube([15, 5, 4], center=true);

        // notch for SD card
        translate([(-case_width / 2) + 30, (-case_length / 2) + 18, (case_height / 2) - 0.75])
            cube([14, 5, 2], center=true);


        // Opening for usb charging plug
        translate([(case_length / 2) - 1, (-case_width / 2) + 31.5, (case_height / 2) - 9])
            cube([5, 11.2, 6.5]);

        // Pinholes for the battery pocket mounting pins
        translate([(-case_length / 2) + 71, (-case_width / 2) + 28.25, (-case_height / 2) + 1.5])
            pinhole(r=2, h=5);
        translate([(case_length / 2) - 12, (-case_width / 2) + 28.25, (-case_height / 2) + 1.5])
            pinhole(r=2, h=5);
        translate([(-case_length / 2) + 71, (case_width / 2) - 30.25, (-case_height / 2) + 1.5])
            pinhole(r=2, h=5);
        translate([(case_length / 2) - 12, (case_width / 2) - 30.25, (-case_height / 2) + 1.5])
            pinhole(r=2, h=5);

        // bottom venting
        translate([(case_length / 2) - 55, (-case_width / 2) + 38, (-case_height / 2) - 3])
            bottom_vent();
        translate([(case_length / 2) - 55, (-case_width / 2) + 48, (-case_height / 2) - 3])
            bottom_vent();
        translate([(case_length / 2) - 55, (-case_width / 2) + 58, (-case_height / 2) - 3])
            bottom_vent();

        // side vent
        translate([(-case_length / 2) - 6, 0, 2])
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
// The pocket will be secured in the enclosure using Dash Tabs
// The pocket also has mounting holes for the doubler and the amp
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


    // Stops to keep the battery in place and to assist in securing pocket to enclosure base
    // Left and right stops
    translate([(-battery_length / 2) + 2.75 - 0.001, (-battery_width / 2) + 10.5 - 0.001, (-battery_height / 2) + 5 - 0.001])
        cube([4.5, 8, battery_height], center=true);
        translate([(-battery_length / 2) + 2.75, (-battery_width / 2) + 10.5, (battery_height / 2) - 0.001])
            battery_pins();
    translate([(battery_length / 2) - 2.75 - 0.001, (-battery_width / 2) + 10.5 - 0.001, (-battery_height / 2) + 5 - 0.001])
        cube([4.5, 8, battery_height], center=true);
        translate([(battery_length / 2) - 2.75, (-battery_width / 2) + 10.5, (battery_height / 2) - 0.001])
            battery_pins();
    translate([(-battery_length / 2) + 2.75 - 0.001, (battery_width / 2) - 10.5, (-battery_height / 2) + 5 - 0.001])
        cube([4.5, 8, battery_height], center=true);
        translate([(-battery_length / 2) + 2.75, (battery_width / 2) - 10.5, (battery_height / 2) - 0.001])
            battery_pins();
    translate([(battery_length / 2) - 2.75 - 0.001, (battery_width / 2) - 10.5, (-battery_height / 2) + 5 - 0.001])
        cube([4.5, 8, battery_height], center=true);
        translate([(battery_length / 2) - 2.75, (battery_width / 2) - 10.5, (battery_height / 2) - 0.001])
            battery_pins();

    // Backward stop
    translate([10, (-battery_width / 2) + 3, (-battery_height / 2) + 5 - 0.001])
        cube([5, 5, battery_height], center=true);
}


module base_top_pinholes() {
    difference() {
        cube([10, 10, case_height], center=true);
        translate([0, 0, (case_height / 2) - 8])
            pinhole(r=3, h=8);
    }
}

module enclosure_top() {
   difference() {
       cube([case_length + 3, case_width + 3, 4], center=true);
       translate([0, 0, 2])
            cube([(case_length - 1), (case_width - 1), 5], center=true);

       // hole for the display
       translate([(case_width / 2) - 30, (-case_length / 2) + 56, -1])
           cube([35.56, 50, 2], center=true);

       // display mounting points
       translate([(case_length / 2) - 62.75, (-case_width / 2) + 11.25, -2])
           cylinder(d=3, h=2);
       translate([(case_length / 2) - 32.25, (-case_width / 2) + 11.25, -2])
           cylinder(d=3, h=2);

       // cut out for the Kailh key
       translate([(-case_width / 2) , (case_length / 4) - 22, -1])
           cube([20, 20, 3], center=true);

       // slot for SD card extender
       translate([(case_width / 2) - 30, (-case_length / 2) + 18, 1.75])
           cube([14, 5, 4], center=true);

    }

    // pins for snapping top onto base
    translate([(-case_length / 2) + 4, (-case_width / 2) + 4, -0.5 - 0.001])
        top_pins_left();
    translate([(-case_length / 2) + 4, (case_width / 2) - 4, -0.5 - 0.001])
        top_pins_right();
    translate([(case_length / 2) - 4, (-case_width / 2) + 4, -0.5 - 0.001])
        top_pins_left();
    translate([(case_length / 2) - 4, (case_width / 2) - 4, -0.5 - 0.001])
        top_pins_right();
}


module top_pins_left() {
    pin(r=3, h=10);
}

module top_pins_right() {
    pin(r=3, h=10);
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

module battery_pins() {
    rotate([180, 180, 90])
        pin(r=2, h=5);
}

