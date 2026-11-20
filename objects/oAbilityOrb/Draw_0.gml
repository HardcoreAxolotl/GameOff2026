transition = min(
    transition + (delta_time / 1000000) / transition_duration,
    1
);
if (transition == 1) transition = 0;

var _g = animcurve_channel_evaluate(
    animation_channel,
    transition
);

shader_set(shColorChange);

var color_to_set = shader_get_uniform(shColorChange, "u_Color");

shader_set_uniform_f(
    color_to_set,
    color_get_red(color) / 255.0,
    color_get_green(color) / 255.0,
    color_get_blue(color) / 255.0
);

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale+0.25*_g, image_yscale+0.25*_g, image_angle, c_white, 1);

shader_reset();

draw_sprite_ext(ability_to_sprite(), image_index, x, y, image_xscale+0.25*_g, image_yscale+0.25*_g, image_angle, c_white, 1);