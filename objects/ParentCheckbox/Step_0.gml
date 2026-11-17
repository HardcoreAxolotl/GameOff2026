// Inherit the parent event
var _device = InputPlayerGetDevice();
var using_gamepad = InputDeviceIsGamepad(_device);

if (in_button || (global.ButtonSelection == SelectionID && using_gamepad)) image_blend = (make_color_rgb(200,200,200));
else image_blend = (c_white);

if (InputPressed(INPUT_VERB.PRIMARY)
&& Layer == global.CurrentUI
&& SelectionID == global.ButtonSelection) {
    show_debug_message("It works for checkboxes too");
    event_user(0);
}