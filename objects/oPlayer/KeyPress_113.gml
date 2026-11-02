if (!softlock) {
    visible = false;
    softlock = true;
    ExplodePlayer(sprite_index, x, y);
    alarm[11] = 60;
}