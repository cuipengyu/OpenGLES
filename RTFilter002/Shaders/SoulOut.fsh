precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;
uniform float time;

void main(){
    
    float duration = 0.5 * (2.0 - vPolaroid);
    float progress = mod(time, duration) / duration;
    float scale = 1.0 + progress;
    float scaledX = 0.5 + (vTextureCoordinate.x - 0.5) / scale;
    float scaledY = 0.5 + (vTextureCoordinate.y - 0.5) / scale;
    
    vec2 scaledTextureCoordinate = vec2(scaledX, scaledY);
    vec4 scaledMask = texture2D(Texture, scaledTextureCoordinate);
    vec4 mask = texture2D(Texture, vTextureCoordinate);
    
    float alpha = 0.5*(1.0 - progress);
    gl_FragColor = mask *(1.0 - alpha) + scaledMask * alpha;

}
//两个相同的纹理 一个不动一个放大 放大之后的像素点与原来的进行混合
