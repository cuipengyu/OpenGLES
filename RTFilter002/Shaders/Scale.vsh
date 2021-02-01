attribute vec4 Position;
attribute vec2 textureCoordinate;
attribute float Polaroid;
uniform float time;
varying vec2 vTextureCoordinate;

void main() {
    
    float duration = (2.0 - Polaroid) * 0.5;
    float time = mod(time, duration);
    float zf = 1.0 + 0.1 * abs(sin(time * (3.1415926 / duration)));
    
    gl_Position = vec4(Position.x * zf, Position.y * zf, Position.zw);
    vTextureCoordinate = textureCoordinate;
}

