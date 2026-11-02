var Layers = [
    layer_get_id("WHITE"),
    layer_get_id("RED"),
    layer_get_id("YELLOW"),
    layer_get_id("GREEN"),
    layer_get_id("CYAN"),
    layer_get_id("BLUE"),
    layer_get_id("MAGENTA"),
    layer_get_id("PURPLE"),
    layer_get_id("ORANGE"),
    layer_get_id("TURQUOISE"),
    layer_get_id("BLACK")
];

if (global.CurrentColor< 0 || global.CurrentColor >= array_length(global.Colors)) return;

var lay_id = layer_get_id("BG");
var back_id = layer_background_get_id(lay_id);

for (var i = 0; i < array_length(Layers); i++) {
    layer_set_visible(Layers[i], i == global.CurrentColor);
}

layer_background_blend(back_id, global.Colors[global.CurrentColor]);
global.CurrentColor = global.CurrentColor;