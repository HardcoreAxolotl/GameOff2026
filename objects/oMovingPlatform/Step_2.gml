x += moveX;
y += moveY;

if (goingToStart && point_distance(x, y, startX, startY) < current_speed) {
    goingToStart = false;
    current_speed = 0;
    alarm[0] = waitTime;
}

if (!goingToStart && point_distance(x, y, endX, endY) < current_speed) {
    goingToStart = true;
    current_speed = 0;
    alarm[0] = waitTime;
}
