if (global.GameStarted) {
    layer_set_visible("PauseMenu", true);
    global.CurrentUI = 2;
}
else {
    layer_set_visible("StartMenu", true);
    global.CurrentUI = 0;
}
layer_set_visible("SettingsMenu", false);
