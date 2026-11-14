varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 u_Color;

void main()
{
    vec4 tex = texture2D(gm_BaseTexture, v_vTexcoord);

    if (abs(tex.r - tex.g) < 0.001 &&
        abs(tex.g - tex.b) < 0.001)
    {
        gl_FragColor = vec4(
            u_Color * tex.rgb,
            tex.a * v_vColour.a
        );
    }
    else
    {
        gl_FragColor = vec4(
            tex.rgb * v_vColour.rgb,
            tex.a * v_vColour.a
        );
    }
}