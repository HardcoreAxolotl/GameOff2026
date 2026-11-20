// Work out which menu layer is currently on screen.
var _menu_name = "";
var _menu_index = -1;

if (layer_get_visible("StartMenu")) {
    _menu_name = "StartMenu";
    _menu_index = 0;
}
else if (layer_get_visible("SettingsMenu")) {
    _menu_name = "SettingsMenu";
    _menu_index = 1;
}
else if (layer_get_visible("PauseMenu")) {
    _menu_name = "PauseMenu";
    _menu_index = 2;
}

// Count the buttons belonging to the visible menu so navigation stays in sync
// with the layout in RoomUI (including the checkboxes, which inherit
// ParentButton).
var _count = 0;
if (_menu_index >= 0) {
    with (ParentButton) {
        if (Layer == _menu_index) _count++;
    }
}
global.ButtonCount = _count;

// Reset the cursor when a different menu opens, and when play resumes.
if (global.LastUIMenu != _menu_name) {
    global.ButtonSelection = 0;
    global.LastUIMenu = _menu_name;
}

if (_count > 0) {
    // Up / Down works for the keyboard, the gamepad d-pad and the left stick.
    if (InputPressed(INPUT_VERB.UP)) {
        if (--global.ButtonSelection < 0) global.ButtonSelection = _count - 1;
    }
    if (InputPressed(INPUT_VERB.DOWN)) {
        if (++global.ButtonSelection >= _count) global.ButtonSelection = 0;
    }

    // Secondary (B / Shift / X) and System (Start / Esc) act as "back".
    if (InputPressed(INPUT_VERB.SECONDARY) || InputPressed(INPUT_VERB.SYSTEM)) {
        if (_menu_name == "SettingsMenu") {
            with (oBackButton) event_user(0);
        }
        else if (_menu_name == "PauseMenu") {
            layer_set_visible("PauseMenu", false);
            global.GamePaused = false;
        }
    }
}
else if (global.GameStarted && InputPressed(INPUT_VERB.SYSTEM)) {
    // Start / Esc opens the pause menu during play.
    global.GamePaused = true;
    global.CurrentUI = 2;
    layer_set_visible("PauseMenu", true);
}
