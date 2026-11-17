#region constants
grav = 0.2;
max_jumps = 1;
jump_force = 3.33333;

acceleration = 0.5;
decceleration = 0.6;
max_speed = 2;

air_control = 0.6; 

enum ABILITIES {
    NONE = 0,
    DOUBLE_JUMP = 1,
    WALL_JUMP = 2,
    GRAVITY_SWAP = 3,
    DASH = 4
}

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
is_walled = false;
is_gravity_swapped = false;

// conditionals
can_dash = false;
can_swap_gravity = false;

// collision
collision = noone;

// other
current_color = -1;
active_ability = starting_ability;
#endregion

if (instance_exists(CheckPoint)) {
    x = CheckPoint.x;
    y = CheckPoint.y;
}
else {
    instance_create_layer(x,y,layer,CheckPoint);
}

/*
alarm 0 is cayote time
alarm 1 is jump buffering
alarm 2 is dash cooldown
alarm 3 is death animation
alarm 11 is death after delay
*/