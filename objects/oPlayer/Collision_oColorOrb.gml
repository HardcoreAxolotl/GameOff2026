if (instance_exists(CheckPoint)) {
    var _inst = instance_find(CheckPoint, 0);

    _inst.x = other.x;
    _inst.y = other.y;
}