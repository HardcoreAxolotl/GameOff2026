if (state) {
    timer++;
    
    // Change room
    if (timer >= duration) {
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