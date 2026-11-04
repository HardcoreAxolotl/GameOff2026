if (global.CurrentColor != ColorID) {
    var Layer = global.Layer;
    
    if (ColorID< 0 || ColorID >= array_length(global.Colors)) return;

    var lay_id = layer_get_id("BG");
    var back_id = layer_background_get_id(lay_id);

    for (var i = 0; i < array_length(Layer); i++) {
        layer_set_visible(Layer[i], i == ColorID);
    }

    layer_background_blend(back_id, global.Colors[ColorID]);
    global.CurrentColor = ColorID;
}