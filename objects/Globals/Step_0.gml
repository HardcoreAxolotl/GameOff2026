var _using_gamepad = InputDeviceIsGamepad(InputPlayerGetDevice());

if (_using_gamepad)
{
    var _last = global.ButtonCount - 1;

    if (InputPressed(INPUT_VERB.UP))
    {
        global.ButtonSelection--;
        if (global.ButtonSelection < 0) global.ButtonSelection = _last;
    }

    if (InputPressed(INPUT_VERB.DOWN))
    {
        global.ButtonSelection++;
        if (global.ButtonSelection > _last) global.ButtonSelection = 0;
    }
}

if (layer_get_visible("StartMenu")) global.ButtonCount = 3;
else if layer_get_visible("PauseMenu") global.ButtonCount = 4;
else if layer_get_visible("SettingsMenu") global.ButtonCount = 5;
