// ==============================
// Vertical collision
// ==============================
if (vspd != 0) {
    var _steps = ceil(abs(vspd));
    var _dir = sign(vspd);

    repeat (_steps) {
        if (place_meeting(x, y + _dir, collision_targets)) {
            vspd = 0;
            break;
        }

        y += _dir;
    }
}

// ==============================
// Horizontal collision
// ==============================
if (hspd != 0) {
    var _steps = floor(abs(hspd));
    var _dir = sign(hspd);

    repeat (_steps) {
        if (place_meeting(x + _dir, y, collision_targets)) {
            hspd = 0;
            dash_timer = 0;     // stop the dash when we hit a wall
            break;
        }

        x += _dir;
    }
}
