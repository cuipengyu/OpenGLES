//
//  RTEditGLTool.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import "RTEditGLTool.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoordinate; //(x,y,z)
    GLKVector2 textureCoordinate; //(s,t)
}RTVertexStruct;

@interface RTEditGLTool ()
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint programID;

@property (nonatomic, assign) GLuint textureID;

@property (nonatomic, assign) GLfloat polaroidValue;

@property (nonatomic, weak) CADisplayLink *displayLink;

@property (nonatomic, assign) CGFloat time;

@property (nonatomic, assign) RTVertexStruct *vertexs;
@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint vShader;
@property (nonatomic, assign) GLuint fShader;

@end

@implementation RTEditGLTool

+ (instancetype)shareInstance{
    static RTEditGLTool * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[RTEditGLTool alloc] init];
      
    });
    return _instance;
}

- (void)setOriginalImage:(UIImage *)originalImage onLayer:(nonnull CAEAGLLayer *)layer{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    CGImageRef imageRef = originalImage.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
 
    self.textureID = [self setTextureByDecodeImage:imageRef width:width height:height];

    //根据纹理大小 调整一下layer的 x,y
    CGFloat ratio = MIN(layer.bounds.size.width/width, layer.bounds.size.height/height);
    CGFloat w = width * ratio;
    CGFloat h = height * ratio;
  
    layer.bounds = CGRectMake(0, 0, w, h);
    //设置顶点、沉浸、帧缓存区 以及视口
    [self setBuffersAndViewPortDependenceLayer:layer];
    
}

- (void)setupProgramWithShaderName:(NSString *)shaderName
{
    GLuint program = glCreateProgram();
    
    GLuint vShader = [self complieShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fShader = [self complieShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    glAttachShader(program, vShader);
    glAttachShader(program, fShader);
    self.vShader = vShader;
    self.fShader = fShader;
    
    glLinkProgram(program);
    
    //激活纹理 将纹理传进去 0代表第一个纹理 1代表第二个
    GLuint textureSlot = glGetUniformLocation(program, "Texture");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    glUniform1f(textureSlot, 0);
    
    GLuint positionSlot = glGetAttribLocation(program, "Position");
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(RTVertexStruct), NULL + offsetof(RTVertexStruct, positionCoordinate));

    GLuint textureCoordinateSlot = glGetAttribLocation(program, "textureCoordinate");
    glEnableVertexAttribArray(textureCoordinateSlot);
    glVertexAttribPointer(textureCoordinateSlot, 2, GL_FLOAT, GL_FALSE, sizeof(RTVertexStruct), NULL + offsetof(RTVertexStruct, textureCoordinate));
    
    GLuint polaroidSlot = glGetAttribLocation(program, "Polaroid");
    if (polaroidSlot != UINT32_MAX) {
        glVertexAttrib1f(polaroidSlot, self.polaroidValue);
    }
   
    
    self.programID = program;
    
}

- (void)setPolaroidEffectValue:(CGFloat)value{
    self.polaroidValue = value;
    GLuint polaroidSlot = glGetAttribLocation(self.programID, "Polaroid");
    if (polaroidSlot != UINT32_MAX) {
        glVertexAttrib1f(polaroidSlot, value);
    }
}

- (void)render{
    
    glUseProgram(self.programID);
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
}

- (void)clear{
    if (self.displayLink) {
        [self.displayLink invalidate];
    }
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_vertexs) {
        free(_vertexs);
        _vertexs = nil;
    }
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }

    glDeleteTextures(1, &_textureID);
    glDeleteShader(_vShader);
    glDeleteShader(_fShader);
    glDeleteRenderbuffers(1, &_renderBuffer);
    glDeleteFramebuffers(1, &_frameBuffer);
    glDeleteProgram(self.programID);
    glReleaseShaderCompiler();
    


}

-(void)startAnimation{
    if (!self.displayLink) {
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerDone)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = displayLink;
    }
}
-(void)timerDone{
    if (self.time == 0) {
        self.time = CFAbsoluteTimeGetCurrent();
    }
    
    GLuint time = glGetUniformLocation(self.programID, "time");
    if (time != UINT32_MAX) {
        glUniform1f(time, CFAbsoluteTimeGetCurrent() - self.time);
    }
    [self render];
}

#pragma mark - Private

- (GLuint)setTextureByDecodeImage:(CGImageRef)imageRef width:(size_t)width height:(size_t)height{
    void *imageData = malloc(width * height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint32_t bitmapInfo = kCGImageAlphaPremultipliedLast;
    CGContextRef imageContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, bitmapInfo);
    CGContextTranslateCTM(imageContext, 0, height);
    CGContextScaleCTM(imageContext, 1, -1);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(imageContext, rect, imageRef);
    

    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
 
    //设置纹理参数 环绕模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);//GL_NEAREST 线性/邻近
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(imageContext, rect);
    CGContextRelease(imageContext);
    free(imageData);
    
    return textureID;
}

 
- (void)setBuffersAndViewPortDependenceLayer:(CAEAGLLayer *)layer{
    //顶点数组
    RTVertexStruct *vertexs = malloc(sizeof(RTVertexStruct) * 4);
    vertexs[0] = (RTVertexStruct){{-1,1,0},{0,1}};//左上
    vertexs[1] = (RTVertexStruct){{-1,-1,0},{0,0}};//左下
    vertexs[2] = (RTVertexStruct){{1,-1,0},{1,0}};//右下
    vertexs[3] = (RTVertexStruct){{1,1,0},{1,1}};//右上
    self.vertexs = vertexs;
    
    //设置顶点缓存区
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(RTVertexStruct)*4, vertexs, GL_DYNAMIC_DRAW);
    self.vertexBuffer = vertexBuffer;
 
    //创建渲染缓冲区并绑定到layer，创建帧缓存区与渲染缓冲区连接，将renderBuffer附着到帧缓存区
    GLuint renderBuffer, frameBuffer;
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    self.renderBuffer = renderBuffer;
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    self.frameBuffer = frameBuffer;
    
    //从renderBuffer获取渲染的宽高并设置视口
    GLint backingWidth, backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    glViewport(0, 0, backingWidth, backingHeight);

}


- (GLuint)complieShaderWithName:(NSString *)shaderName type:(GLenum)type{
    
    GLuint shader = glCreateShader(type);
    
    NSString *fileExt = type == GL_VERTEX_SHADER ? @"vsh" : @"fsh";
    NSString *shaderPath = [[NSBundle bundleForClass:[self class]] pathForResource:shaderName ofType:fileExt];
    NSString *content = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:nil];
    int length = (int)[content length];
    const char *shaderContent = [content UTF8String];
    glShaderSource(shader, 1, &shaderContent, &length);
    glCompileShader(shader);
    
    return shader;
}
@end
