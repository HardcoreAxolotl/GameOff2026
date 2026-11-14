// Update transition progress
transition = min(
    transition + (delta_time / 1000000) / transition_duration,
    1
);

// Evaluate animation curve
var _blend = animcurve_channel_evaluate(
    blend_channel,
    transition
);

_blend = clamp(_blend, 0, 1);

// Keep both layers visible during the transition
layer_set_visible(global.Layer[current_layer], true);
layer_set_visible(global.Layer[target_layer], true);

// Interpolate background color
var _color = color_transition(
    color_get_red(current_color),
    color_get_green(current_color),
    color_get_blue(current_color),

    color_get_red(target_color),
    color_get_green(target_color),
    color_get_blue(target_color),

    _blend
);

layer_background_blend(back_id, _color);

// Crossfade tilemap layers
global.LayerAlpha[current_layer] = 1 - _blend;
global.LayerAlpha[target_layer] = _blend;

// Finish transition
if (transition >= 1) {
    // Guarantee exact final values
    global.LayerAlpha[current_layer] = 0;
    global.LayerAlpha[target_layer] = 1;

    layer_background_blend(back_id, target_color);

    layer_set_visible(global.Layer[current_layer], false);
    layer_set_visible(global.Layer[target_layer], true);

    instance_destroy();
}