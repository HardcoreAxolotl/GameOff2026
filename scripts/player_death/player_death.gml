function player_death(){
    show_debug_message("player_death script was executed - room: " + room_get_name(room));
    fade_to_room(room, 60, c_black);
}