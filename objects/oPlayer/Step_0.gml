if (global.GamePaused || is_dead) {
    image_speed = 0;
}
else {
    image_speed = 1;
}

if (is_gravity_swapped) {
    image_yscale = -1;
}
else {
    image_yscale = 1;
}

if (move_dir != 0) { 
        image_xscale = move_dir;
}

if (dash_timer > 0) {
    sprite_index = sPlayerDash;
}
else if (is_grounded) {
    
    if (move_dir != 0) { 
        image_xscale = move_dir;
        sprite_index = sPlayerMove; 
    }
    else { sprite_index = sPlayerIdle; }
}
else if (is_walled) {
    image_xscale = wall_dir;
    sprite_index = sPlayerWallSlide;
}
else {
    sprite_index = sPlayerJump;
    if (vspd < 0) image_index = 0;
    if (vspd > 1) image_index = 2;
}