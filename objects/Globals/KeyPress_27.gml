global.GamePaused = !global.GamePaused;
if (global.GamePaused) {
    layer_set_visible("StartMenu", false);
    layer_set_visible("PauseMenu", true);
}
else {
    if (!global.GameStarted) layer_set_visible("StartMenu", true);
    else layer_set_visible("StartMenu", false);
        
    layer_set_visible("PauseMenu", false);
    layer_set_visible("Settings", false);
}