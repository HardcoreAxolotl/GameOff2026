if (!global.GameStarted && global.CurrentUI != 1) {
    global.GamePaused = false;
    layer_set_visible("StartMenu", true);
}
else layer_set_visible("StartMenu", false);
    
if (global.IHateTheCoolBG) {
    var _fx = fx_create("_filter_tintfilter");
    fx_set_parameter(_fx, "g_TintCol", [0.8, 0.8, 0.8, 1]);
    
    layer_set_fx("BG", _fx);
}

ReinitGlobals();