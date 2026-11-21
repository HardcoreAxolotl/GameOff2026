
#region state_checks

    // Stop movement processing if the player is dead or the game is paused.
    if (is_dead || global.GamePaused) exit;

#endregion


#region input

    // Read player input.
    var key_left       = InputCheck(INPUT_VERB.LEFT);
    var key_right      = InputCheck(INPUT_VERB.RIGHT);
    var key_down       = InputCheck(INPUT_VERB.DOWN);
    var key_up         = InputCheck(INPUT_VERB.UP);

    // Jump uses pressed/released states for buffering and variable jump height.
    var key_start_jump = InputPressed(INPUT_VERB.PRIMARY);
    var key_stop_jump  = InputReleased(INPUT_VERB.PRIMARY);

    // Ability input is triggered once per button press.
    var key_ability    = InputPressed(INPUT_VERB.SECONDARY);

    // Convert left/right input into a horizontal movement direction.
    // -1 = Left, 0 = Idle, 1 = Right.
    move_dir = key_right - key_left;

#endregion


#region collision_detection

    // Update the collision tilemap when the active color changes.
    if (global.CurrentColor != current_color) {
        current_color = global.CurrentColor;
        collision = global.TilemapCollision[current_color];
    }

    // Check for ground contact.
    // When gravity is reversed, the ceiling becomes the ground.
    if (is_gravity_swapped) {
        is_grounded = place_meeting(x, y - 3, collision);
    }
    else {
        is_grounded = place_meeting(x, y + 3, collision);
    }

    // Detect walls.
    // Returns -1 for a wall on the right, 1 for a wall on the left.
    wall_dir = place_meeting(x - 3, y, collision)
             - place_meeting(x + 3, y, collision);

    is_walled = wall_dir != 0;

    // Gravity Swap prevents wall interactions while equipped.
    if (is_unwallable) {
        wall_dir = 0;
        is_walled = false;
    }

#endregion


#region timers

    // Wall jump steering lock.
    if (wall_jump_lock_timer > 0) {
        wall_jump_lock_timer--;
    }

    // Dash cooldown.
    if (dash_cooldown > 0) {
        dash_cooldown--;
    }

#endregion


#region ability_state

    // Determine the maximum number of jumps allowed.
    max_jumps = (active_ability == ABILITIES.DOUBLE_JUMP) ? 2 : 1;

    // Reset jump and gravity swap availability when touching a surface.
    if (is_grounded || is_walled) {
        jumps = 0;
        can_swap_gravity = true;
    }

    // Restore dash availability when grounded or touching a wall.
    if (dash_timer <= 0 && (is_grounded || is_walled)) {
        can_dash = true;
    }

    // Gravity Swap prevents wall interactions.
    is_unwallable = (active_ability == ABILITIES.GRAVITY_SWAP);

#endregion


#region ability_input

    // Activate abilities using the secondary input.
    if (key_ability) {

        // DASH
        if (active_ability == ABILITIES.DASH) {

            // Only dash if available and not on cooldown.
            if (can_dash && dash_cooldown <= 0 && dash_timer <= 0) {

                // Use movement direction, or facing direction if idle.
                dash_dir = (move_dir != 0) ? move_dir : sign(image_xscale);

                if (dash_dir == 0) {
                    dash_dir = 1;
                }

                // Initialize dash.
                dash_timer = dash_duration;
                dash_cooldown = dash_cooldown_time;

                can_dash = false;
                is_dashing = true;

                // Apply dash velocity.
                hspd = dash_dir * dash_speed;
                vspd = 0;
            }
        }
    }

#endregion


#region movement

    // Handle active dash separately from normal movement.
    if (dash_timer > 0) {

        #region dash

            // Continue applying dash velocity.
            dash_timer--;

            is_dashing = true;

            hspd = dash_dir * dash_speed;
            vspd = 0;

            // End dash and restore normal horizontal speed limits.
            if (dash_timer <= 0) {
                is_dashing = false;
                hspd = clamp(hspd, -max_speed, max_speed);
            }

        #endregion

    }
    else {

        // Normal movement is active when not dashing.
        is_dashing = false;


        #region horizontal_movement

            // Start with the player's input direction.
            var control_dir = move_dir;

            // Prevent immediately steering back into the wall after a wall jump.
            if (wall_jump_lock_timer > 0
                && control_dir != 0
                && control_dir == -sign(wall_dir)) {

                control_dir = 0;
            }

            // Apply acceleration when movement input is held.
            if (control_dir != 0) {

                // Air movement has reduced acceleration.
                var _accel = is_grounded
                    ? acceleration
                    : acceleration * air_control;

                // Accelerate in the current movement direction.
                if (sign(hspd) == control_dir) {

                    // Increase speed until maximum speed is reached.
                    if (abs(hspd) < max_speed) {

                        hspd += _accel * control_dir;

                        // Prevent exceeding maximum speed.
                        if (abs(hspd) > max_speed) {
                            hspd = control_dir * max_speed;
                        }
                    }

                    // Reduce excess speed if above the normal maximum.
                    else if (abs(hspd) > max_speed) {

                        hspd -= sign(hspd) * decceleration;

                        if (abs(hspd) < max_speed) {
                            hspd = control_dir * max_speed;
                        }
                    }
                }
                else {

                    // Accelerate in the opposite direction to change direction.
                    hspd += _accel * control_dir;
                }
            }
            else {

                // Apply friction when no horizontal input is held.
                if (hspd != 0) {

                    var _friction = decceleration;

                    hspd -= sign(hspd) * _friction;

                    // Stop completely when remaining speed is very small.
                    if (abs(hspd) < _friction) {
                        hspd = 0;
                    }
                }
            }

        #endregion


        #region jumping

            // Temporary state used to distinguish a Gravity Swap jump
            // from a normal jump.
            var _gravity_swap_jump = false;

            // Remember gravity direction before the swap.
            // This determines which direction the jump should launch.
            var _jump_gravity_swapped = is_gravity_swapped;


            #region jump_buffer

                // Store jump input for 10 frames.
                // This allows the player to jump shortly before landing.
                if (key_start_jump) {
                    alarm[1] = 10;
                }

            #endregion


            #region gravity_swap

                // Gravity Swap consumes the buffered jump.
                // It only activates when gravity swapping is available.
                if (active_ability == ABILITIES.GRAVITY_SWAP
                    && alarm[1] >= 0
                    && can_swap_gravity) {

                    // Save the previous gravity direction.
                    _jump_gravity_swapped = is_gravity_swapped;

                    // Reverse gravity.
                    is_gravity_swapped = !is_gravity_swapped;

                    // Prevent another swap until the player touches a surface.
                    can_swap_gravity = false;

                    // Mark this as a Gravity Swap jump.
                    _gravity_swap_jump = true;

                    // Consume the buffered jump input.
                    alarm[1] = -1;
                }

            #endregion


            #region gravity_and_falling

                // Determine whether the player is currently moving with gravity.
                var moving_with_gravity = is_gravity_swapped
                    ? vspd < 0
                    : vspd > 0;

                // Apply reduced gravity while sliding down a wall.
                if (is_walled && !is_grounded && moving_with_gravity) {
                    vspd += is_gravity_swapped ? -wall_grav : wall_grav;
                }
                else {
                    // Apply normal gravity.
                    vspd += is_gravity_swapped ? -grav : grav;
                }

                // Limit falling speed or wall sliding speed.
                if (is_walled && !is_grounded) {

                    vspd = is_gravity_swapped
                        ? max(vspd, -max_slide)
                        : min(vspd, max_slide);
                }
                else {

                    vspd = is_gravity_swapped
                        ? max(vspd, -max_fall)
                        : min(vspd, max_fall);
                }

            #endregion


            #region execute_jump

                // GRAVITY SWAP JUMP
                if (_gravity_swap_jump) {

                    // Check whether this jump is also a wall jump.
                    var _can_wall_jump = is_walled && !is_grounded;

                    if (_can_wall_jump) {

                        // Apply horizontal wall jump force.
                        hspd = wall_dir * hwall_jump_force;

                        // Launch away from the surface using the OLD gravity direction.
                        vspd = _jump_gravity_swapped
                            ? vwall_jump_force
                            : -vwall_jump_force;

                        // Prevent immediate steering back into the wall.
                        wall_jump_lock_timer = wall_jump_lock_duration;
                    }
                    else {

                        // Launch away from the surface using the OLD gravity direction.
                        vspd = _jump_gravity_swapped
                            ? jump_force
                            : -jump_force;
                    }

                    // Count the jump and update grounded state.
                    jumps++;
                    is_grounded = false;
                }


                // NORMAL JUMP
                // Disabled when Gravity Swap is equipped.
                else if (active_ability != ABILITIES.GRAVITY_SWAP
                    && alarm[1] >= 0
                    && jumps < max_jumps) {

                    var _can_wall_jump = is_walled && !is_grounded;

                    // Only jump when grounded, wall jumping, or using Double Jump.
                    if (is_grounded || _can_wall_jump || max_jumps >= 2) {

                        if (_can_wall_jump) {

                            // Apply horizontal wall jump force.
                            hspd = wall_dir * hwall_jump_force;

                            // Launch away from the wall.
                            vspd = is_gravity_swapped
                                ? vwall_jump_force
                                : -vwall_jump_force;

                            wall_jump_lock_timer = wall_jump_lock_duration;
                        }
                        else {

                            // Normal jump direction depends on gravity.
                            vspd = is_gravity_swapped
                                ? jump_force
                                : -jump_force;
                        }

                        // Consume the buffered input and count the jump.
                        jumps++;

                        alarm[1] = -1;
                        is_grounded = false;
                    }
                }

            #endregion


            #region variable_jump_height

                // Reduce upward velocity when jump is released early.
                // The direction depends on the current gravity direction.
                if (key_stop_jump) {

                    if (is_gravity_swapped) {

                        if (vspd > 0) {
                            vspd *= 0.6;
                        }
                    }
                    else {

                        if (vspd < 0) {
                            vspd *= 0.6;
                        }
                    }
                }

            #endregion

        #endregion

    }

#endregion
