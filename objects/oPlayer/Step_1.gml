var key_left        = InputCheck(INPUT_VERB.LEFT);
var key_right       = InputCheck(INPUT_VERB.RIGHT);
var key_down       = InputCheck(INPUT_VERB.DOWN);
var key_start_jump  = InputPressed(INPUT_VERB.ACCEPT);
var key_stop_jump   = InputReleased(INPUT_VERB.ACCEPT);
var key_dash        = InputPressed(INPUT_VERB.SPECIAL);

if (is_dead) exit;

move_dir = key_right - key_left;

if (global.CurrentColor != color_id_cache) {
    color_id_cache = global.CurrentColor;
    collision_targets = global.TilemapCollision[color_id_cache];
}

is_grounded = place_meeting(x, y + 1, collision_targets);

#region movement

#region move
if (move_dir != 0) {
    var _accel = is_grounded
    ? acceleration
    : acceleration * air_control;
    
    hspd +=_accel * move_dir;
}
else {
    if (hspd != 0) hspd -= (hspd > 0) ? decceleration : -decceleration;
}

hspd = clamp(hspd, -max_speed, max_speed)
#endregion

#region jump
if (is_grounded) {
    jumps = 0;
}

vspd += grav;

if (key_start_jump) {
    alarm[1] = 10;
}

if (alarm[1] >= 0 && jumps < max_jumps) {
    vspd = 0;
    vspd -= jump_force;
    jumps++;
    alarm[1] = -1;
}

if (key_stop_jump) {
    vspd *= 0.6;
}
#endregion

#endregion
