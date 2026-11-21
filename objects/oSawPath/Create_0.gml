if (Saw.object_index != oSawTrap) {
    instance_destroy(self);
    show_error("Saw Path recived a none Saw instance", true);
}

position = {
    _x: x,
    _y: y
}

Saw.points[ID]  = position;