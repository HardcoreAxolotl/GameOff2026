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

#macro COLORS [c_white, c_red, c_yellow, c_lime, c_aqua, c_blue, make_color_rgb(128,  0, 255), make_color_rgb(16, 16, 16)]

//audio_play_sound(snShiftOfTheme, 1, true);

InitGlobals();

room_goto(StartMenu); 