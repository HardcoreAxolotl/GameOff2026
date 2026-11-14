shader_set(shColorChange);

var color_to_set = shader_get_uniform(shColorChange, "u_Color");
var color = COLORS[color_id_cache];
shader_set_uniform_f(color_to_set, color_get_red(color), color_get_green(color), color_get_blue(color));

draw_self();
shader_reset();