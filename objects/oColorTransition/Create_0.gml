transition = 0;
transition_duration = 1; // second

global.LayerAlpha[target_layer] = 0;
layer_set_visible(global.Layer[target_layer], true);
blend_channel = animcurve_get_channel(acColorTransition, 0);
