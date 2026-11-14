// ==============================
// Delta time
// ==============================

// Seconds per frame.
// Prevent huge movements after a long frame.
var _dt = clamp(delta_time / 1000000, 0, 0.05);

// ==============================
// Find target
// ==============================

if (!instance_exists(target)) {
    target = instance_find(oPlayer, 0);
}

// ==============================
// Zoom
// ==============================

zoom_target = clamp(zoom_target, zoom_min, zoom_max);

var _zoom_alpha = 1;

if (zoom_smooth > 0) {
    _zoom_alpha = 1 - power(0.001, _dt / zoom_smooth);
}

zoom = lerp(zoom, zoom_target, _zoom_alpha);

var _view_w = base_width / zoom;
var _view_h = base_height / zoom;

// ==============================
// Rotation
// ==============================

var _rotation_alpha = 1;

if (rotation_smooth > 0) {
    _rotation_alpha = 1 - power(0.001, _dt / rotation_smooth);
}

camera_rotation += angle_difference(
    rotation_target,
    camera_rotation
) * _rotation_alpha;

// ==============================
// Manual focus timer
// ==============================

if (focus_enabled && focus_time > 0) {
    focus_time -= _dt;

    if (focus_time <= 0) {
        focus_enabled = false;
    }
}

// ==============================
// Look ahead
// ==============================

var _look_target_x = 0;
var _look_target_y = 0;

if (look_ahead_enabled && instance_exists(target)) {

    if (look_ahead_x_enabled) {
        var _vx = target.x - target.xprevious;

        _look_target_x = clamp(
            _vx * look_ahead_frames,
            -look_ahead_max_x,
            look_ahead_max_x
        );
    }

    if (look_ahead_y_enabled) {
        var _vy = target.y - target.yprevious;

        _look_target_y = clamp(
            _vy * look_ahead_frames,
            -look_ahead_max_y,
            look_ahead_max_y
        );
    }
}

var _look_alpha = 1;

if (look_ahead_smooth > 0) {
    _look_alpha = 1 - power(0.001, _dt / look_ahead_smooth);
}

look_x = lerp(look_x, _look_target_x, _look_alpha);
look_y = lerp(look_y, _look_target_y, _look_alpha);

// ==============================
// Calculate target camera position
// ==============================

var _desired_x = camera_x;
var _desired_y = camera_y;

// Manual focus overrides player tracking
if (focus_enabled) {

    _desired_x = focus_x;
    _desired_y = focus_y;

}
else if (follow_enabled && instance_exists(target)) {

    var _target_x = target.x + follow_offset_x + look_x;
    var _target_y = target.y + follow_offset_y + look_y;

    // ==============================
    // Dead zone
    // ==============================

    if (deadzone_enabled) {

        var _dx = _target_x - camera_x;
        var _dy = _target_y - camera_y;

        var _half_w = deadzone_width * 0.5;
        var _half_h = deadzone_height * 0.5;

        if (abs(_dx) > _half_w) {
            _desired_x = camera_x
                + sign(_dx) * (abs(_dx) - _half_w);
        }

        if (abs(_dy) > _half_h) {
            _desired_y = camera_y
                + sign(_dy) * (abs(_dy) - _half_h);
        }

    }
    else {

        _desired_x = _target_x;
        _desired_y = _target_y;

    }
}

// ==============================
// Smooth following
// ==============================

var _follow_alpha = 1;

if (follow_smooth > 0) {
    _follow_alpha = 1 - power(0.001, _dt / follow_smooth);
}

if (snap_pending) {

    camera_x = _desired_x;
    camera_y = _desired_y;

    snap_pending = false;

}
else {

    camera_x = lerp(camera_x, _desired_x, _follow_alpha);
    camera_y = lerp(camera_y, _desired_y, _follow_alpha);

}

// ==============================
// Camera boundaries
// ==============================

if (bounds_enabled) {

    // Account for camera rotation when calculating
    // the actual space occupied by the camera.

    var _cos = abs(dcos(camera_rotation));
    var _sin = abs(dsin(camera_rotation));

    var _extent_x = (
        _cos * _view_w +
        _sin * _view_h
    ) * 0.5;

    var _extent_y = (
        _sin * _view_w +
        _cos * _view_h
    ) * 0.5;

    var _min_x = bounds_left + _extent_x;
    var _max_x = bounds_right - _extent_x;

    var _min_y = bounds_top + _extent_y;
    var _max_y = bounds_bottom - _extent_y;

    if (_min_x > _max_x) {
        camera_x = (bounds_left + bounds_right) * 0.5;
    }
    else {
        camera_x = clamp(camera_x, _min_x, _max_x);
    }

    if (_min_y > _max_y) {
        camera_y = (bounds_top + bounds_bottom) * 0.5;
    }
    else {
        camera_y = clamp(camera_y, _min_y, _max_y);
    }
}

// ==============================
// Camera shake
// ==============================

var _shake_x = 0;
var _shake_y = 0;
var _shake_angle = 0;

if (shake_time > 0) {

    var _strength = shake_amount * clamp(
        shake_time / max(shake_duration, 0.001),
        0,
        1
    );

    _shake_x = random_range(-_strength, _strength);
    _shake_y = random_range(-_strength, _strength);

    _shake_angle = random_range(
        -shake_angle_amount,
        shake_angle_amount
    );

    shake_time = max(0, shake_time - _dt);

}

// ==============================
// Apply camera
// ==============================

// Normalize angle to 0-360
var _final_angle = (camera_rotation + _shake_angle) % 360;

if (_final_angle < 0) {
    _final_angle += 360;
}

camera_set_view_size(
    camera_id,
    _view_w,
    _view_h
);

camera_set_view_angle(
    camera_id,
    _final_angle
);

camera_set_view_pos(
    camera_id,
    camera_x + _shake_x - _view_w * 0.5,
    camera_y + _shake_y - _view_h * 0.5
);