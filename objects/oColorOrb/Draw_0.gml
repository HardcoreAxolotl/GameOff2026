// Inherit the parent event
event_inherited();

transition = min(
    transition + (delta_time / 1000000) / transition_duration,
    1
);
if (transition == 1) transition = 0;

var _g = animcurve_channel_evaluate(
    animation_channel,
    transition
);
image_xscale = 1+.25*_g;
image_yscale = 1+.25*_g;