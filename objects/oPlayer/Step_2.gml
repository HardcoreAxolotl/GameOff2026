if (!global.GamePaused) {
    // ==============================
    // Vertical collision
    // ==============================
    if (vspd != 0) {
        var _steps = ceil(abs(vspd));
        var _dir = sign(vspd);
    
        repeat (_steps) {
            if (place_meeting(x, y + _dir, collision)) {
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
            if (place_meeting(x + _dir, y, collision)) {
                hspd = 0;
                dash_timer = 0;     // stop the dash when we hit a wall
                is_dashing = false;
                break;
            }
    
            x += _dir;
        }
    }
}