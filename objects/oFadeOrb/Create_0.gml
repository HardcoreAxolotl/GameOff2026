ColorID = 0;

if (instance_exists(creator))
{
    // Position
    x = creator.x;
    y = creator.y;
    
    ColorID = creator.ColorID;

    // Sprite
    sprite_index = creator.sprite_index;
    image_index = creator.image_index;
    image_speed = creator.image_speed;
    image_xscale = creator.image_xscale;
    image_yscale = creator.image_yscale;
    image_angle = creator.image_angle;

    // Appearance
    image_blend = creator.image_blend;
    image_alpha = creator.image_alpha;
}

if (ColorID == -1) ColorID = global.CurrentColor;