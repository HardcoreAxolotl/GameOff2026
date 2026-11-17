if (!global.GameStarted) {
    global.GamePaused = false;
    layer_set_visible("StartMenu", true);
}
else layer_set_visible("StartMenu", false);
    
ReinitGlobals();