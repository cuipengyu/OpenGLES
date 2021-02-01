precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;

void main(void) {
    
    vec2 st = vTextureCoordinate.xy;
    st.x = st.x * 2.0;
    st.y = st.y * 2.0;
    if (st.x >= 1.0) {
        st.x = st.x - 1.0;
    }
    if (st.y >= 1.0) {
        st.y = st.y - 1.0;
    }
    vec4 mask = texture2D(Texture, st);
    gl_FragColor = vec4(max(min(mask.rgb, 1.0 - vPolaroid),vPolaroid), 1);
}
