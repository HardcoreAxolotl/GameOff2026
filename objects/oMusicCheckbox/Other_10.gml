// Inherit the parent event
event_inherited();

// enabled = music on (stop when false)
if (enabled) {
    if (!audio_is_playing(snShiftOfTheme)) audio_play_sound(snShiftOfTheme, 1, true);
}
else {
    audio_stop_sound(snShiftOfTheme);
}
