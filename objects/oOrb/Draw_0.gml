transition = min(
    transition + (delta_time / 1000000) / transition_duration,
    1
);
if (transition == 1) transition = 0;

var _y = animcurve_channel_evaluate(
    animation_channel,
    transition
);


draw_sprite_ext(sprite_index, image_index, x, y+2.5*_y, image_xscale, image_yscale, image_angle, c_white, 1);