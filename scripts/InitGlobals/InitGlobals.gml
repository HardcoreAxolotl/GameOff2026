function InitGlobals() {
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

    for (var i = 0; i < array_length(global.Layer); i++) {
        global.TilemapCollision[i] = layer_tilemap_get_id(global.Layer[i]);
    }
    
    global.LayerAlpha = array_create(array_length(global.Layer), 1);

    global.LayerAlphaUniform = shader_get_uniform(
        shLayerAlpha,
        "u_alpha"
    );
    
    for (var i = 0; i < array_length(global.Layer); i++) {
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
    
        layer_script_begin(global.Layer[i], _begin);
        layer_script_end(global.Layer[i], _end);
    }
    
    // Settings
    global.TransitionForHaters = false;
    global.IHateTheCoolBG = false;
    global.SFX = true;

    // Game state
    global.GameStarted = false;
    global.GamePaused = false;
    global.GameSettings = false;
    
    // UI
    global.ButtonSelection = 0;
    global.ButtonCount = 3;
    global.CurrentUI = 0;
    
    // Color
    global.CurrentColor = 0;
    global.PrivousColor = 0;
}
