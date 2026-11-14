shader_set(shColorChange);

var color_to_set = shader_get_uniform(shColorChange, "u_Color");
var color = COLORS[global.CurrentColor];

shader_set_uniform_f(
    color_to_set,
    color_get_red(color) / 255.0,
    color_get_green(color) / 255.0,
    color_get_blue(color) / 255.0
);

draw_self();
shader_reset();