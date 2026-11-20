/// oMovingWall - configurable moving solid platform
/// Supports carrying oPlayer, including gravity-flipped riding.

// Movement configuration (override in instance creation code)
move_x = 0;        // total horizontal travel distance from start position
move_y = 0;        // total vertical travel distance from start position
move_speed = 1;    // pixels per step
wait_time = 0;     // steps to wait at each end of travel

// Runtime state
xstart_pos = x;
ystart_pos = y;
progress = 0;      // distance traveled from start toward (start + move_x/move_y)
dir_sign = 1;      // 1 = forward, -1 = backward
wait_timer = 0;
xprev = x;
yprev = y;
