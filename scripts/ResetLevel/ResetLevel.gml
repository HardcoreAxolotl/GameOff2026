function ResetLevel(){
    global.CurrentColor = 0;
    
    if (instance_exists(CheckPoint)) {
        instance_destroy(CheckPoint);
    }
}