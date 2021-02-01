precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;

void main(){
    vec4 mask = texture2D(Texture, vTextureCoordinate);
    gl_FragColor = vec4(max(min(mask.rgb, 1.0 - vPolaroid),vPolaroid), 1);
}
