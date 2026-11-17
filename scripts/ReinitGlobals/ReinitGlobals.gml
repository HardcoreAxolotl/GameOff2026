function ReinitGlobals(_reset_state = true) {
    show_debug_message("ReinitGlobals script was executed - room: " + room_get_name(room) + " - reset state: " + string(_reset_state));

    if (_reset_state) {
        global.CurrentColor = 0;
        global.PrivousColor = 0;
    }

    global.Layer = [
        layer_get_id("WHITE"),
        layer_get_id("RED"),
        layer_get_id("YELLOW"),
        layer_get_id("GREEN"),
        layer_get_id("CYAN"),
        layer_get_id("BLUE"),
        layer_get_id("PURPLE"),
        layer_get_id("BLACK")
    ];

    global.TilemapCollision = array_create(array_length(global.Layer));

    global.LayerAlpha = array_create(array_length(global.Layer), 1);

    global.LayerAlphaUniform = shader_get_uniform(
        shLayerAlpha,
        "u_alpha"
    );

    for (var i = 0; i < array_length(global.Layer); i++) {
        var _layer = global.Layer[i];

        // Reinitialize tilemap and visibility
        global.TilemapCollision[i] = layer_tilemap_get_id(_layer);

        layer_set_visible(_layer, i == global.CurrentColor);

        // Register shader callbacks
        var _context = { index: i };

        var _begin = method(_context, function() {
            if (event_type == ev_draw && event_number == ev_draw_normal) {
                shader_set(shLayerAlpha);

                shader_set_uniform_f(
                    global.LayerAlphaUniform,
                    global.LayerAlpha[self.index]
                );
            }
        });

        var _end = method(_context, function() {
            if (event_type == ev_draw && event_number == ev_draw_normal) {
                shader_reset();
            }
        });

        layer_script_begin(_layer, _begin);
        layer_script_end(_layer, _end);
    }

    // A room rebuild restores the saved layer visibility and background tint,
    // so re-apply the color the player actually has right now.
    var _bg_layer = layer_get_id("BG");
    if (_bg_layer != -1) {
        var _bg = layer_background_get_id(_bg_layer);
        if (_bg != -1) layer_background_blend(_bg, COLORS[global.CurrentColor]);
    }
}