event_inherited();

if (array_length(points) == 0 || ColorID != global.CurrentColor) exit;

var p = points[point];

var dist = point_distance(x, y, p._x, p._y);
var dir = point_direction(x, y, p._x, p._y);

if (dist <= MoveSpeed) {
    x = p._x;
    y = p._y;

    if (BackAndForth) {
        if (point == 0) point_dir = 1;
        else if (point == array_length(points) - 1) point_dir = -1;

        point += point_dir;
    }
    else {
        point++;

        if (point >= array_length(points)) point = 0;
    }
}
else {
    x += lengthdir_x(MoveSpeed, dir);
    y += lengthdir_y(MoveSpeed, dir);
}