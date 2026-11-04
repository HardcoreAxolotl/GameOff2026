// Select target
var _targetX = endX, _targetY = endY;

if (goingToStart) {
    _targetX = startX;
    _targetY = startY;
}

// Calculate direction
var _dirX = _targetX - x;
var _dirY = _targetY - y;

// Normalize movement
var _length = point_distance(0, 0, _dirX, _dirY);

if (_length > current_speed) {
    moveX = (_dirX / _length) * current_speed;
    moveY = (_dirY / _length) * current_speed;
} else {
    moveX = _dirX;
    moveY = _dirY;
}