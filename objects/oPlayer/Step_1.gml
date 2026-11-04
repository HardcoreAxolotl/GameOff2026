var key_left = InputCheck(INPUT_VERB.LEFT);
var key_right = InputCheck(INPUT_VERB.RIGHT);
var key_start_jump = InputPressed(INPUT_VERB.ACCEPT);
var key_stop_jump = InputReleased(INPUT_VERB.ACCEPT);

var collision = [COLLISION[global.CurrentColor], oMovingPlatform];

// Identify the platform beneath the player
groundPlatform = instance_place(x, y + 1, oMovingPlatform);

is_grounded = place_meeting(x, y + 1, collision);

var move = key_right - key_left;
hspd = move * walkspd;

// Gravity and jumping
if (is_grounded) {
    if (key_start_jump) {
        vspd = jfr;
    }
    else {
        vspd = 0;
    }
}
else {
    vspd += grv;
}

if (key_stop_jump && vspd < 0) {
    vspd *= 0.3;
}

if (move != 0) image_xscale = move;