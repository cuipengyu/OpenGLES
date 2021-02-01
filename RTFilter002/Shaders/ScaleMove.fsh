precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;
uniform float time;

void main(){
    
    float duration = 0.5 * (2.0 - vPolaroid);
    float progress = mod(time, duration) / duration;
    float scale = 1.0 + 0.05 * sin(3.1415926*progress);
    float offsetCoords = 0.01 * sin(3.1415926*progress);
 
    vec2 scaledTextureCoordinate = vec2(0.5, 0.5) + (vTextureCoordinate-vec2(0.5,0.5))/scale;
   
    vec4 mask = texture2D(Texture, scaledTextureCoordinate);
    vec4 mask1 = texture2D(Texture, scaledTextureCoordinate + offsetCoords);
    vec4 mask2 = texture2D(Texture, scaledTextureCoordinate - offsetCoords);
 
    gl_FragColor = vec4(mask.r, mask1.g, mask2.b, mask.a);

}
