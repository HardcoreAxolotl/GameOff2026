function color_transition(r1, g1, b1, r2, g2, b2, t) {
    t = clamp(t, 0, 1);

    return make_color_rgb(
        lerp(r1, r2, t),
        lerp(g1, g2, t),
        lerp(b1, b2, t)
    );
}