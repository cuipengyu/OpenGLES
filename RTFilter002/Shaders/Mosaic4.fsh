precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;
const vec2 TextureSize = vec2(800.0,800.0);
const vec2 MosaicSize = vec2(20.0,20.0);

void main(){
    float x = MosaicSize.x * (1.0+vPolaroid);
    float y = MosaicSize.y * (1.0+vPolaroid);
    vec2 intXY = vec2(TextureSize.x*vTextureCoordinate.x, TextureSize.y*vTextureCoordinate.y);
    vec2 mosaicXY = vec2(floor(intXY.x/x)*x, floor(intXY.y/y)*y);
    vec2 mosaicST = vec2(mosaicXY.x/TextureSize.x, mosaicXY.y/TextureSize.y);
    vec4 mask = texture2D(Texture, mosaicST);
    gl_FragColor = vec4(mask.rgb, 1);
}
//1.假设纹理图大小是800*800 算出实际纹理的像素点位置,从外面传入大小更好
//2.算出小马赛克的坐标
//3.换算出纹理坐标 其实就是相当于一个精度换算，以马赛克的size为最小精度
