// ==============================
// Horizontal collision
// ==============================

if (place_meeting(x + hspd, y, COLLISION[global.CurrentColor])) {
    while (!place_meeting(x + sign(hspd), y, COLLISION[global.CurrentColor])) {
        x += sign(hspd);
    }

    hspd = 0;
} else {
    if (!softlock) x += hspd;
}

// ==============================
// Vertical collision
// ==============================

if (place_meeting(x, y + vspd, COLLISION[global.CurrentColor])) {
    while (!place_meeting(x, y + sign(vspd), COLLISION[global.CurrentColor])) {
        y += sign(vspd);
    }

    vspd = 0;
} else {
    if (!softlock) y += vspd;
}

if (place_meeting(x, y, COLLISION[global.CurrentColor]) && softlocked) {
    alarm[10] = 60;
    softlock = true;
    softlocked = false;
}