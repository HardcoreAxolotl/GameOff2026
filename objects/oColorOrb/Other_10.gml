var lay_id = layer_get_id("BG");
var back_id = layer_background_get_id(lay_id);

switch (ColorID) {
    case 0:
        layer_background_blend(back_id, c_white);
}