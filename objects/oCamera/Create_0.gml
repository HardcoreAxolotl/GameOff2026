// ==============================
// Camera initialization
// ==============================

view_enabled = true;
view_visible[0] = true;

camera_id = view_camera[0];
owns_camera = false;

// Create a camera if the room has none
if (camera_id == -1) {
    camera_id = camera_create_view(
        0, 0,
        256, 224,
        0, -1,
        -1, -1,
        0, 0
    );

    view_camera[0] = camera_id;
    owns_camera = true;
}

// Disable GameMaker's automatic object tracking.
// We control the camera ourselves.
camera_set_view_target(camera_id, -1);

// ==============================
// Camera dimensions
// ==============================

base_width = camera_get_view_width(camera_id);
base_height = camera_get_view_height(camera_id);

if (base_width <= 0) base_width = 640;
if (base_height <= 0) base_height = 360;

// Current camera center
camera_x = camera_get_view_x(camera_id) + base_width * 0.5;
camera_y = camera_get_view_y(camera_id) + base_height * 0.5;

// ==============================
// Target
// ==============================

target = noone;
follow_enabled = true;

// ==============================
// Following
// ==============================

// Time to reach approximately 99.9% of the target position.
follow_smooth = 0.18;

// Camera offset
follow_offset_x = 0;
follow_offset_y = -24;

// ==============================
// Dead zone
// ==============================

deadzone_enabled = true;

deadzone_width = 48;
deadzone_height = 32;

// ==============================
// Look ahead
// ==============================

look_ahead_enabled = true;

look_ahead_x_enabled = true;
look_ahead_y_enabled = false;

look_ahead_frames = 6;

look_ahead_max_x = 48;
look_ahead_max_y = 24;

look_ahead_smooth = 0.15;

look_x = 0;
look_y = 0;

// ==============================
// Zoom
// ==============================

// 1 = normal
// >1 = zoom in
// <1 = zoom out

zoom = 1;
zoom_target = 1;

zoom_min = 0.65;
zoom_max = 2.0;

zoom_smooth = 0.25;

// ==============================
// Rotation
// ==============================

camera_rotation = camera_get_view_angle(camera_id);
rotation_target = camera_rotation;

rotation_smooth = 0.2;

// ==============================
// Camera boundaries
// ==============================

bounds_enabled = true;

bounds_left = 0;
bounds_top = 0;
bounds_right = room_width;
bounds_bottom = room_height;

// ==============================
// Camera shake
// ==============================

shake_time = 0;
shake_duration = 0.25;

shake_amount = 0;
shake_angle_amount = 0;

// ==============================
// Manual camera focus
// ==============================

focus_enabled = false;

focus_x = camera_x;
focus_y = camera_y;

focus_time = 0;

// ==============================
// Initialization
// ==============================

snap_pending = true;