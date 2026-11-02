// ==============================
// Horizontal collision
// ==============================

if (place_meeting(x + hspd, y, COLLISION)) {
    while (!place_meeting(x + sign(hspd), y, COLLISION)) {
        x += sign(hspd);
    }

    hspd = 0;
} else {
    x += hspd;
}

// ==============================
// Vertical collision
// ==============================

if (place_meeting(x, y + vspd, COLLISION)) {
    while (!place_meeting(x, y + sign(vspd), COLLISION)) {
        y += sign(vspd);
    }

    vspd = 0;
} else {
    y += vspd;
}