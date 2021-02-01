precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;
const float mosaicSize = 0.03;
void main(void)
{
    float len = mosaicSize * (1.0 + vPolaroid);
    float TR = 0.866025;
    float TB = 1.5;
    
    float x = vTextureCoordinate.x;
    float y = vTextureCoordinate.y;
    
    int wx = int(x/TB/len);
    int wy = int(y/TR/len);
    
    vec2 v1, v2, vn;
    if (wx/2 * 2 == wx) {
        if (wy/2 * 2 == wy) {
            v1 = vec2(len*1.5*float(wx), len*TR*float(wy));
            v2 = vec2(len*1.5*float(wx+1), len*TR*float(wy+1));
        }else{
            v1 = vec2(len*1.5*float(wx), len*TR*float(wy+1));
            v2 = vec2(len*1.5*float(wx+1), len*TR*float(wy));
        }
    } else {
        if (wy/2 * 2 == wy) {
            v1 = vec2(len*1.5*float(wx), len*TR*float(wy+1));
            v2 = vec2(len*1.5*float(wx+1), len*TR*float(wy));
        }else{
            v1 = vec2(len*1.5*float(wx), len*TR*float(wy));
            v2 = vec2(len*1.5*float(wx+1), len*TR*float(wy+1));
        }
    }
    
    float s1 = sqrt(pow(v1.x - x,2.0) + pow(v1.y - y,2.0));
    float s2 = sqrt(pow(v2.x - x,2.0) + pow(v2.y - y,2.0));
    if (s1 < s2) {
        vn = v1;
    }else{
        vn = v2;
    }
    gl_FragColor = texture2D(Texture, vn);
}
