if (global.GameStarted) {
    layer_set_visible("PauseMenu", true);
    global.CurrentUI = 3;
}
else {
    layer_set_visible("StartMenu", true);
    global.CurrentUI = 1;
}
layer_set_visible("SettingsMenu", false);