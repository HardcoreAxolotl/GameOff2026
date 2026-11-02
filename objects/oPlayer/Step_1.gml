var key_left = InputCheck(INPUT_VERB.LEFT);
var key_right = InputCheck(INPUT_VERB.RIGHT);
var key_start_jump = InputPressed(INPUT_VERB.ACCEPT);
var key_stop_jump = InputReleased(INPUT_VERB.ACCEPT);

is_grounded = place_meeting(x,y+1, COLLISION[global.CurrentColor]);

var move = key_right - key_left;
hspd = move * walkspd;
vspd += grv;

if (is_grounded) {
    if (key_start_jump) vspd = jfr;
}

if (key_stop_jump && vspd<0) {
    vspd *= 0.3;
} 

if (move != 0) image_xscale = move;
