if (is_dead || global.GamePaused) exit;

// Input
var key_left       = InputCheck(INPUT_VERB.LEFT);
var key_right      = InputCheck(INPUT_VERB.RIGHT);
var key_down       = InputCheck(INPUT_VERB.DOWN);
var key_up       = InputCheck(INPUT_VERB.UP);
var key_start_jump = InputPressed(INPUT_VERB.PRIMARY);
var key_stop_jump  = InputReleased(INPUT_VERB.PRIMARY);
var key_ability    = InputPressed(INPUT_VERB.SECONDARY);

move_dir = key_right - key_left;

// Collision
if (global.CurrentColor != current_color) {
    current_color = global.CurrentColor;
    collision = global.TilemapCollision[current_color];
}

if (is_gravity_swapped) {
    is_grounded = place_meeting(x, y - 3, collision);
}
else {
    is_grounded = place_meeting(x, y + 3, collision);
}

wall_dir = place_meeting(x - 3, y, collision)
         - place_meeting(x + 3,  y, collision);

is_walled = wall_dir != 0;

// Timers
if (wall_jump_lock_timer > 0) wall_jump_lock_timer--;
if (dash_cooldown > 0) dash_cooldown--;

// Ability state
max_jumps = (active_ability == ABILITIES.DOUBLE_JUMP) ? 2 : 1;

if (is_grounded || is_walled) {
    jumps = 0;
    can_swap_gravity = true;
}

if (dash_timer <= 0 && (is_grounded || is_walled)) {
    can_dash = true;
}

// Ability input
if (key_ability) {
    switch (active_ability) {
        case ABILITIES.GRAVITY_SWAP:
            if (can_swap_gravity) {
                is_gravity_swapped = !is_gravity_swapped;
            }

            can_swap_gravity = false;
        break;

        case ABILITIES.DASH:
            if (can_dash && dash_cooldown <= 0 && dash_timer <= 0) {
                dash_dir = (move_dir != 0) ? move_dir : sign(image_xscale);
                if (dash_dir == 0) dash_dir = 1;
                
                dash_timer = dash_duration;
                dash_cooldown = dash_cooldown_time;
                can_dash = false;
                is_dashing = true;
                hspd = dash_dir * dash_speed;
                vspd = 0;
            }
        break;
    }
}

#region movement

if (dash_timer > 0) {
    dash_timer--;
    is_dashing = true;
    hspd = dash_dir * dash_speed;
    vspd = 0;

    if (dash_timer <= 0) {
        is_dashing = false;
        hspd = clamp(hspd, -max_speed, max_speed);
    }
}
else {
    is_dashing = false;

    #region move

    var control_dir = move_dir;
    if (wall_jump_lock_timer > 0 && control_dir != 0 && control_dir == -sign(wall_dir)) {
        // avoid instantly steering back into the wall right after a wall jump
        control_dir = 0;
    }

    if (control_dir != 0) {
        var _accel = is_grounded
            ? acceleration
            : acceleration * air_control;

        if (sign(hspd) == control_dir) {
            if (abs(hspd) < max_speed) {
                hspd += _accel * control_dir;
                if (abs(hspd) > max_speed) hspd = control_dir * max_speed;
            }
            else if (abs(hspd) > max_speed) {
                hspd -= sign(hspd) * decceleration;
                if (abs(hspd) < max_speed) hspd = control_dir * max_speed;
            }
        }
        else {
            hspd += _accel * control_dir;
        }
    }
    else {
        if (hspd != 0) {
            var _friction = decceleration;
            hspd -= sign(hspd) * _friction;
            if (abs(hspd) < _friction) hspd = 0;
        }
    }

    #endregion

    #region jump

    if (is_walled && !is_grounded) {
        if (vspd > 0.5) {
            if (is_gravity_swapped) {
                vspd += grav;
            }
            else {
                vspd -= grav;
            }
        }
        else {
            if (is_gravity_swapped) {
                vspd -= grav;
            }
            else {
                vspd += grav;
            }
        }
    }
    else {
        if (is_gravity_swapped) {
            vspd -= grav;
        }
        else {
            vspd += grav;
        }
    }

    if (is_walled) {
        if (is_gravity_swapped) {
            vspd = max(vspd, -max_slide);
        }
        else {
            vspd = min(vspd, max_slide);
        }
    }
    else {
        if (is_gravity_swapped) {
            vspd = max(vspd, -max_fall);
        }
        else {
            vspd = min(vspd, max_fall);
        }
    }

    if (key_start_jump) {
        alarm[1] = 10;
    }

    if (alarm[1] >= 0 && jumps < max_jumps) {
        var _can_wall_jump = is_walled
            && !is_grounded;

        if (is_grounded || _can_wall_jump || max_jumps >= 2) {
            if (_can_wall_jump) {
                hspd = wall_dir * hwall_jump_force;
                vspd = is_gravity_swapped ? vwall_jump_force : -vwall_jump_force;
                wall_jump_lock_timer = wall_jump_lock_duration;
            }
            else {
                vspd = is_gravity_swapped ? jump_force : -jump_force;
            }

            jumps++;
            alarm[1] = -1;
            is_grounded = false;
        }
    }

    if (key_stop_jump) {
        if (is_gravity_swapped) {
            if (vspd > 0) vspd *= 0.6;
        }
        else {
            if (vspd < 0) vspd *= 0.6;
        }
    }

    #endregion
}

#endregion