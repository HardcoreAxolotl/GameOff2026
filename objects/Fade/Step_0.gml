if (state) {
    if (!global.GamePaused || above_gui) timer++;
    
    // Change room
    if (timer >= duration) {
        if (reset) ResetLevel(); // Generally wanted for moving between levels 
            
        room_goto(targetRoom);
        
        state =  false;
    }
}
else {
    timer--;
    
    if (timer <= 0) {
        instance_destroy();
    }
}

alpha = timer / duration;