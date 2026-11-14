if (move_dir != 0) { 
        image_xscale = move_dir;
}

if (alarm[2] > 0) {
    sprite_index = sPlayerDash;
}
else if (is_grounded) {
    
    if (move_dir != 0) { 
        image_xscale = move_dir;
        sprite_index = sPlayerMove; 
    }
    else { sprite_index = sPlayerIdle; }
}
else if (wall_dir != 0) {
    image_xscale = wall_dir;
    sprite_index = sPlayerWallSlide;
}
else {
    sprite_index = sPlayerJump;
    if (vspd < 0) image_index = 0;
    if (vspd > 1) image_index = 2;
}
