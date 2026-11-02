image_speed = 1;
if (is_grounded) {
     if (floor(hspd) != 0) {
        sprite_index = sPlayerJog;
    }
    else {
        sprite_index = sPlayerIdle;
    }
}
else {
    sprite_index = sPlayerJump;
    if (vspd < 0) {
        image_index = 0;
    }
    else if (image_index > 2) {
        image_speed = 0;
    }
}