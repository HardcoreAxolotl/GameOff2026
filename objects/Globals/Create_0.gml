/*
WHITE: 0
RED: 1
YELLOW: 2
GREEN: 3
CYAN: 4
BLUE: 5
PURPLE: 6
BLACK: 7
*/

global.Colors = [
    c_white,
    c_red,
    c_yellow,
    c_lime,
    c_aqua,
    c_blue,
    make_color_rgb(128,  0, 255),
    make_color_rgb(8, 8, 8)
];

global.Layer = [
    layer_get_id("WHITE"),
    layer_get_id("RED"),
    layer_get_id("YELLOW"),
    layer_get_id("GREEN"),
    layer_get_id("CYAN"),
    layer_get_id("BLUE"),
    layer_get_id("PURPLE"),
    layer_get_id("BLACK")
];


global.CurrentColor = 0;

global.health = 3;

room_goto(Level_0);