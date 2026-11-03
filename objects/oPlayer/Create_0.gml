COLLISION = [
    layer_tilemap_get_id(layer_get_id("WHITE")),
    layer_tilemap_get_id(layer_get_id("RED")),
    layer_tilemap_get_id(layer_get_id("YELLOW")),
    layer_tilemap_get_id(layer_get_id("GREEN")),
    layer_tilemap_get_id(layer_get_id("CYAN")),
    layer_tilemap_get_id(layer_get_id("BLUE")),
    layer_tilemap_get_id(layer_get_id("MAGENTA")),
    layer_tilemap_get_id(layer_get_id("PURPLE")),
    layer_tilemap_get_id(layer_get_id("ORANGE")),
    layer_tilemap_get_id(layer_get_id("TURQUOISE")),
    layer_tilemap_get_id(layer_get_id("BLACK"))
];

softlocked = true;
softlock = false;

hspd = 0;
vspd = 0;
walkspd = 1.5;
grv = 0.1;
jfr = -2.25;

is_grounded = false;

global.health = 3;

visible = true;

if (instance_exists(CheckPoint)) {
    var _inst = instance_find(CheckPoint, 0);
    x = _inst.x;
    y = _inst.y;
}
else {
    instance_create_depth(0,0,0, CheckPoint);
}