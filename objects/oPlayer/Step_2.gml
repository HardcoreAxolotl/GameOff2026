var collision = [COLLISION[global.CurrentColor], oMovingPlatform];

// ==============================
// Moving Platform displacement
// ==============================

var _platformX = 0;
var _platformY = 0;

if (groundPlatform != noone && instance_exists(groundPlatform)) {
    _platformX = groundPlatform.x - groundPlatform.xprevious;
    _platformY = groundPlatform.y - groundPlatform.yprevious;
}

var _moveX = hspd + _platformX;
var _moveY = vspd + _platformY;

// ==============================
// Vertical collision FIRST
// ==============================

if (place_meeting(x, y + _moveY, collision)) {
    while (_moveY != 0 && !place_meeting(x, y + sign(_moveY), collision)) {
        y += sign(_moveY);
    }

    vspd = 0;
}
else {
    if (!softlock) y += _moveY;
}

// ==============================
// Horizontal collision SECOND
// ==============================

if (place_meeting(x + _moveX, y, collision)) {
    while (_moveX != 0 && !place_meeting(x + sign(_moveX), y, collision)) {
        x += sign(_moveX);
    }

    hspd = 0;
}
else {
    if (!softlock) x += _moveX;
}

// ==============================
// Softlock detection
// ==============================

if (place_meeting(x, y, collision) && softlocked) {
    alarm[10] = 60;
    softlock = true;
    softlocked = false;
}