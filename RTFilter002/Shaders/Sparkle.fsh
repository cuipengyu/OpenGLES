precision highp float;
uniform sampler2D Texture;
varying vec2 vTextureCoordinate;
varying float vPolaroid;
uniform float time;

void main(){
    
    float duration = 0.3 * (2.0 - vPolaroid);
    float progress = mod(time, duration) / duration;
    
    vec4 mask = texture2D(Texture, vTextureCoordinate);
    
    vec4 white = vec4(1,1,1,1);
  
    if(progress > 0.6){
        gl_FragColor = mask * (1.0 - progress) + white * progress;
    } else if(progress > 0.5) {
        gl_FragColor = vec4(mask.r,1,1,1);
    }else if(progress > 0.4) {
        gl_FragColor = vec4(1,mask.g,1,1);
    }else if(progress > 0.3) {
        gl_FragColor = vec4(1,1,mask.b,1);
    }else if(progress > 0.2) {
        gl_FragColor = vec4(0,0,0,0);
    }else {
        gl_FragColor = mask;
    }
 

}
