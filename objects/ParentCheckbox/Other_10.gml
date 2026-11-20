// Shared checkbox behaviour. Every checkbox leaf calls event_inherited() from
// its User Event 0 before applying its own setting, so the toggle lives here.
// This also makes gamepad/keyboard activation (event_user(0)) toggle the box,
// which previously only happened through the mouse event.
enabled = !enabled;
image_index = enabled;
