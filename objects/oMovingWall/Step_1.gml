/// Move platform and carry/push player (Begin Step, before player movement/collision)
if (global.GamePaused) exit;

xprev = x;
yprev = y;

var dx = 0;
var dy = 0;
var travel = point_distance(0, 0, move_x, move_y);

if (travel > 0 && move_speed > 0) {
    if (wait_timer > 0) {
        wait_timer--;
    }
    else {
        var nx = progress + move_speed * dir_sign;
        if (nx >= travel) {
            nx = travel;
            dir_sign = -1;
            if (wait_time > 0) wait_timer = wait_time;
        }
        else if (nx <= 0) {
            nx = 0;
            dir_sign = 1;
            if (wait_time > 0) wait_timer = wait_time;
        }

        progress = nx;
        var tx = (travel == 0) ? 0 : (move_x / travel) * progress;
        var ty = (travel == 0) ? 0 : (move_y / travel) * progress;
        var target_x = xstart_pos + tx;
        var target_y = ystart_pos + ty;

        dx = target_x - x;
        dy = target_y - y;
    }
}

if (dx == 0 && dy == 0) exit;

// Carry player if riding on this platform (supports gravity flip)
var player = instance_exists(oPlayer) ? instance_find(oPlayer, 0) : noone;
var riding = false;

if (player != noone && !player.is_dead) {
    var grav_flipped = player.is_gravity_swapped;

    if (!grav_flipped) {
        // Normal gravity: player stands on top of platform
        with (oPlayer) {
            if (!is_gravity_swapped && (place_meeting(x, y + 1, other) || place_meeting(x, y + 2, other) || place_meeting(x, y + 3, other))) {
                riding = true;
            }
        }
    }
    else {
        // Gravity flipped: player stands on bottom side of platform
        with (oPlayer) {
            if (is_gravity_swapped && (place_meeting(x, y - 1, other) || place_meeting(x, y - 2, other) || place_meeting(x, y - 3, other))) {
                riding = true;
            }
        }
    }

    if (riding) {
        with (oPlayer) {
            if (dx != 0) x += dx;
            if (dy != 0) y += dy;
        }
    }
}

// Move platform
x += dx;
y += dy;

// Basic push: if platform now overlaps player, try to move player out
if (instance_exists(oPlayer)) {
    with (oPlayer) {
        if (place_meeting(x, y, other)) {
            var pdx = other.x - other.xprevious;
            var pdy = other.y - other.yprevious;

            if (pdx != 0) {
                var sgn = sign(pdx);
                repeat (ceil(abs(pdx)) + 2) {
                    if (!place_meeting(x, y, other)) break;
                    if (!(place_meeting(x + sgn, y, collision) || place_meeting(x + sgn, y, oMovingWall))) {
                        x += sgn;
                    }
                    else {
                        break;
                    }
                }
            }

            if (pdy != 0) {
                var sgn2 = sign(pdy);
                repeat (ceil(abs(pdy)) + 2) {
                    if (!place_meeting(x, y, other)) break;
                    if (!(place_meeting(x, y + sgn2, collision) || place_meeting(x, y + sgn2, oMovingWall))) {
                        y += sgn2;
                    }
                    else {
                        break;
                    }
                }
            }
        }
    }
}
