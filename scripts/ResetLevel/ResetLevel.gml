function ResetLevel(){
    ReinitGlobals();
    
    var lay_id = layer_get_id("BG");
    var back_id = layer_background_get_id(lay_id);
    
    layer_background_blend(back_id, COLORS[0]);
    
    if (instance_exists(CheckPoint)) {
        instance_destroy(CheckPoint);
    }
}