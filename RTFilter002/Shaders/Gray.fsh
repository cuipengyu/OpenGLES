precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;
void main(){
    vec4 mask = texture2D(Texture, vTextureCoordinate);
    float lub = mask.b;
    float lur = abs(mask.r + (mask.b - mask.r) * vPolaroid);
    float lug = abs(mask.g + (mask.b - mask.g) * vPolaroid);
    gl_FragColor = vec4(vec3(lur,lug,lub), 1);
}

