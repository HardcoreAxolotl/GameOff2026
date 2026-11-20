if (other.ColorID == -1) exit;
if (instance_exists(CheckPoint)) {
    var _inst = instance_find(CheckPoint, 0);

    _inst.x = other.x;
    _inst.y = other.y;
    
    _inst.image_xscale = image_xscale;
    _inst.image_yscale = image_yscale;
    
    active_ability = other.Ability;
    _inst.active_ability = other.Ability;
    _inst.is_gravity_swapped = is_gravity_swapped;
}