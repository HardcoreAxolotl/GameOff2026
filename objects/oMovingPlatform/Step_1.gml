// Select  target
var _targetX = endX, _targetY = endY;
if (goingToStart) {
    _targetX = startX;
    _targetY = startY;
}

// Set movement
moveX = sign(_targetX - x) * current_speed;
moveY = sign(_targetY - y) * current_speed;
