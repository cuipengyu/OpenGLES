attribute vec4 Position;
attribute vec2 textureCoordinate;
attribute float Polaroid;
varying vec2 vTextureCoordinate;
varying float vPolaroid;

void main() {
    gl_Position = Position;
    vTextureCoordinate = textureCoordinate;
    vPolaroid = Polaroid;
}
