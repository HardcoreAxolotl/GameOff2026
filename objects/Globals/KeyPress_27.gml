if (global.GameStarted) {
    global.GamePaused = !global.GamePaused;
    if (global.GamePaused) {
        global.CurrentUI = 2;
        layer_set_visible("PauseMenu", true);
    }
    else {
        layer_set_visible("PauseMenu", false);
        layer_set_visible("Settings", false);
    }
}