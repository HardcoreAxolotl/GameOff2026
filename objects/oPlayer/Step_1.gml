if (is_dead || global.GamePaused) exit;
    
var key_left        = InputCheck(INPUT_VERB.LEFT);
var key_right       = InputCheck(INPUT_VERB.RIGHT);
var key_down       = InputCheck(INPUT_VERB.DOWN);
var key_start_jump  = InputPressed(INPUT_VERB.PRIMARY);
var key_stop_jump   = InputReleased(INPUT_VERB.PRIMARY);
var key_ability        = InputPressed(INPUT_VERB.SECONDARY);

move_dir = key_right - key_left;

if (global.CurrentColor != color_id_cache) {
    color_id_cache = global.CurrentColor;
    collision = global.TilemapCollision[color_id_cache];
}

if (is_gravity_swapped)  is_grounded = place_meeting(x, y - 1, collision);
else is_grounded = place_meeting(x, y + 1, collision);


var mc = place_meeting(x-1, y, collision) || place_meeting(x+1, y, collision);
is_walled = mc;

max_jumps = (active_ability == ABILITIES.DOUBLE_JUMP) ? 2 : 1;

if (key_ability) {
    switch (active_ability) {
        case ABILITIES.GRAVITY_SWAP:
            if (can_swap_gravity) is_gravity_swapped = !is_gravity_swapped;
            can_swap_gravity = false;
        break;
    
        case ABILITIES.DASH:
            // TODO: Add dash ability
        break;
    }
}

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
    can_swap_gravity = true;
}

if (is_gravity_swapped) vspd -= grav;
else vspd += grav;

if (key_start_jump) {
    alarm[1] = 10;
}

if (alarm[1] >= 0 && jumps < max_jumps) {
    if (max_jumps < 2 && !is_grounded) exit;
    vspd = 0;
    if (is_gravity_swapped) vspd += jump_force;
    else vspd -= jump_force;
    jumps++;
    alarm[1] = -1;
}

if (key_stop_jump) {
    vspd *= 0.6;
}
#endregion

#endregion
