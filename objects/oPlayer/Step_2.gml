// ==============================
// Horizontal collision
// ==============================

if (place_meeting(x + hspd, y, COLLISION[global.CurrentColor])) {
    while (!place_meeting(x + sign(hspd), y, COLLISION[global.CurrentColor])) {
        x += sign(hspd);
    }

    hspd = 0;
} else {
    x += hspd;
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
    y += vspd;
}