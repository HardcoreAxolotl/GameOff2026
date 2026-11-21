if (ColorID == -1) {
    other.active_ability = Ability;

    instance_create_layer(
        x, y,
        layer,
        oFadeOrb,
        {
            creator: id
        }
    );
}
else if (global.CurrentColor != ColorID) {

    if (ColorID < 0 || ColorID >= array_length(COLORS)) return;

    var lay_id = layer_get_id("BG");
    var back_id = layer_background_get_id(lay_id);

    if (global.TransitionForHaters) {
        instance_create_layer(
            x, y,
            layer,
            oColorTransitionDisabled,
            {
                current_color: COLORS[global.CurrentColor],
                target_color: COLORS[ColorID],
                back_id: back_id,
                current_layer: global.CurrentColor,
                target_layer: ColorID
            }
        );
    }
    else {
        instance_create_layer(
            x, y,
            layer,
            oColorTransition,
            {
                current_color: COLORS[global.CurrentColor],
                target_color: COLORS[ColorID],
                back_id: back_id,
                current_layer: global.CurrentColor,
                target_layer: ColorID
            }
        );
    }

    global.CurrentColor = ColorID;

    instance_create_layer(
        x, y,
        layer,
        oFadeOrb,
        {
            creator: id
        }
    );
}

instance_destroy();