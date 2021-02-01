precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;

void main(void) {
    
    vec2 st = vTextureCoordinate.xy;
    float y = st.y;
    if (st.y < 1.0/3.0) {
        y = st.y + 1.0/3.0;
    } else if(st.y > 2.0/3.0){
        y = st.y - 1.0/3.0;
    }
    vec4 mask = texture2D(Texture, vec2(st.x, y));
    gl_FragColor = vec4(max(min(mask.rgb, 1.0 - vPolaroid),vPolaroid), 1);
}
