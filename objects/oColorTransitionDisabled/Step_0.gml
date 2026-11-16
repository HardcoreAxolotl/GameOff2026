// Make target layer visible
layer_set_visible(global.Layer[current_layer], false);
layer_set_visible(global.Layer[target_layer], true);

// Set background color
layer_background_blend(back_id, target_color);

// Set layer alpha
global.LayerAlpha[current_layer] = 0;
global.LayerAlpha[target_layer] = 1;

// Finish
instance_destroy();