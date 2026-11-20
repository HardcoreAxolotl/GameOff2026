// Shared by every button and checkbox. Highlights the current selection and
// activates it with the primary verb. The active menu is taken from the
// visible UI layer rather than global.CurrentUI, so a stale CurrentUI cannot
// stop the controls from working.
var _layer_name = "";
switch (Layer) {
    case 0: _layer_name = "StartMenu"; break;
    case 1: _layer_name = "SettingsMenu"; break;
    case 2: _layer_name = "PauseMenu"; break;
}

var _is_active = (_layer_name != "" && layer_get_visible(_layer_name))
                 && (SelectionID == global.ButtonSelection);

var _color = COLORS[clamp(global.CurrentColor, 0, array_length(COLORS) - 1)];
var _dark = make_color_rgb(
    color_get_red(_color) * 0.6,
    color_get_green(_color) * 0.6,
    color_get_blue(_color) * 0.6
);
image_blend = _is_active ? _dark : _color;

if (_is_active && InputPressed(INPUT_VERB.PRIMARY)) {
    event_user(0);
}
