/// @function fade_to_room
/// @arg {room} room The target room
/// @arg {real} duration Fade duration
/// @arg {color} color Fade color
/// @arg {reset} reset Reset Room (for playable levels)
/// @arg {above_gui} above_gui Ignore GUI stop fade
function fade_to_room(_room, _dur, _color, _reset = false, _above_gui = false) {
    var _inst = instance_create_depth(0, 0, 0, Fade);

    with (_inst) {
        targetRoom = _room;
        duration = _dur;
        color = _color;
        
        reset = _reset; // Generally wanted for moving between levels 
        above_gui = _above_gui; // Generally wanted for moving between levels 
    }
}