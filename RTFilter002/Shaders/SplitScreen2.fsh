precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;

void main(void) {
    
    vec2 st = vTextureCoordinate.xy;
    if (st.y <= 0.5) {
        st.y = st.y + 0.25;
    } else {
        st.y = st.y - 0.25;
    }
    vec4 mask = texture2D(Texture, st);
    gl_FragColor = vec4(max(min(mask.rgb, 1.0 - vPolaroid),vPolaroid), 1);
}
