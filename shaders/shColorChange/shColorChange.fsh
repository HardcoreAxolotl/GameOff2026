varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 u_Color;

void main()
{
    vec4 tex = texture2D(gm_BaseTexture, v_vTexcoord);

    if (!(tex.r == tex.g && tex.g == tex.b))
    {
        tex.rgb *= u_Color;
    }

    gl_FragColor = tex * v_vColour;
}