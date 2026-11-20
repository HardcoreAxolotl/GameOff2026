shader_set(shColorChange);

var color_to_set = shader_get_uniform(shColorChange, "u_Color");

// ColorID is defined in the object's variable definitions. -1 is the sentinel
// for "use the current world colour" (see oAbilityOrb), and instances such as
// oFadeOrb inherit that value when they copy it from their creator.
var color_index = ColorID;
if (!is_real(color_index) || color_index < 0 || color_index >= array_length(COLORS)) {
    color_index = global.CurrentColor;
}

var color = COLORS[color_index];

shader_set_uniform_f(
    color_to_set,
    color_get_red(color) / 255.0,
    color_get_green(color) / 255.0,
    color_get_blue(color) / 255.0
);

draw_self();

shader_reset();