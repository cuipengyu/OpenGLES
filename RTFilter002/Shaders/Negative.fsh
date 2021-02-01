precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;

void main(void) {
    
    vec2 st = vTextureCoordinate.xy;
    vec4 mask = texture2D(Texture, st);
    gl_FragColor = vec4(abs(vPolaroid - mask.rgb), 1);
}
