#region constants
grav = 0.2;
wall_grav = 0.05;
max_jumps = 1;
jump_force = 3.33333;

hwall_jump_force = 5;
vwall_jump_force = 3.666666;
wall_jump_lock_duration = 8;

acceleration = 0.5;
decceleration = 0.6;
max_speed = 2;
max_fall = 10;
max_slide = 2.5;

air_control = 0.6; 

dash_speed = 8;
dash_duration = 10;
dash_cooldown_time = 18;

enum ABILITIES { // You can have only 1 ability active at a time so no need to think about ability compatability with other abilities
    NONE = 0,
    DOUBLE_JUMP = 1,
    GRAVITY_SWAP = 2,
    DASH = 3
}

#endregion

#region runtime
// movement
hspd = 0;  
vspd = 0;
move_dir = 0;
wall_dir = 0;
jumps = 0;
wall_jump_lock_timer = 0;

// states
is_dead = false;
is_grounded = false;
is_dashing = false;
is_walled = false;
is_unwallable = false;
is_gravity_swapped = false;

// conditionals
can_dash = false;
can_swap_gravity = false;

// timers
dash_timer = 0;
dash_cooldown = 0;
dash_dir = 1;

// collision
collision = noone;

// other
current_color = -1;
active_ability = starting_ability;
#endregion

if (instance_exists(CheckPoint)) {
    x = CheckPoint.x;
    y = CheckPoint.y;
    active_ability = CheckPoint.active_ability;
    is_gravity_swapped = CheckPoint.is_gravity_swapped; 
    image_xscale = CheckPoint.image_xscale;
    image_yscale = CheckPoint.image_yscale;
}
else {
    var inst = instance_create_layer(x,y,layer,CheckPoint);
    inst.active_ability = active_ability;
    inst.is_gravity_swapped = is_gravity_swapped;
}

if (!instance_exists(Existed)) {
    global.NewLevel = true;
    instance_create_layer(x,y,layer,Existed);
}

/*
alarm 0 is cayote time
alarm 1 is jump buffering
alarm 2 is dash cooldown
alarm 3 is death animation
alarm 11 is death after delay
*/