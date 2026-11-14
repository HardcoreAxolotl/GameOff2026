#region constants
grav = 0.2;
max_jumps = 1;
jump_force = 3.33333;

acceleration = 0.5;
decceleration = 0.6;
max_speed = 2;

air_control = 0.6; 

#endregion

#region runtime
// movement
hspd = 0;  
vspd = 0;
move_dir = 0;
wall_dir = 0;
jumps = 0;

// states
is_dead = false;
is_grounded = false;
is_dashing = false;

// collision
collision_targets = noone;

// colors
color_id_cache = -1;
#endregion

/*
alarm 0 is cayote time
alarm 1 is jump buffering
alarm 2 is dash cooldown
alarm 3 is death animation
alarm 11 is death after delay
*/