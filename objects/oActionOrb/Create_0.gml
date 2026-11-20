image_blend = c_white;
transition = 0;
transition_duration = 2.5; // second

color = c_white;
if (ColorID == -1) color = COLORS[global.CurrentColor];
else color = COLORS[ColorID];

animation_channel = animcurve_get_channel(acOrbAnimation, 0);

function ability_to_sprite() {
    switch (Ability) {
    	case 0:
            return sAirOrb;
            
        case 1:
            return sJumpOrb;
            
        case 2:
            return sGravityOrb;
            
        case 3:
            return sDashOrb;
    }
}