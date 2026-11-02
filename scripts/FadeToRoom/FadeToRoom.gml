/// @function fade_to_room
/// @arg {room} room The target room
/// @arg {real} duration Fade duration
/// @arg {color} color Fade color
function fade_to_room(_room, _dur, _color, _reset) {
    var _inst = instance_create_depth(0, 0, 0, Fade);

    with (_inst) {
        targetRoom = _room;
        duration = _dur;
        color = _color;
        
        reset = _reset;
    }
}