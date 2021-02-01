//
//  RTStrechResultView.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/28.
//

#import "RTStrechResultView.h"

static CGFloat kDefaultStrechBeginY = 0.5;
static CGFloat kDefaultStrechEndY = 0.7;

typedef struct {
    GLKVector3 positionCoord; //顶点坐标;
    GLKVector2 textureCoord;  //纹理坐标;
} RTStrechVertics;

@interface RTStrechResultView()<GLKViewDelegate>
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGFloat textureWidth;
@property (nonatomic, assign) CGFloat textureHeight;

@property (nonatomic, assign) RTStrechVertics *vertices;

@property (nonatomic, assign) CGFloat strechTextureBeginY;
@property (nonatomic, assign) CGFloat strechTextureEndY;

@property (nonatomic, assign) CGFloat strechHeight;

//临时创建的帧缓存和纹理缓存
@property (nonatomic, assign) GLuint frameBuffer;

@end
@implementation RTStrechResultView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:self.context];
        glClearColor(0, 0, 0, 1);
        self.vertices = malloc(sizeof(RTStrechVertics)*8);
        self.delegate = self;
       
    }
    return self;
}

- (void)dealloc{
    
    free(self.vertices);
    glBindTexture(GL_TEXTURE_2D, 0);
    GLuint textureName = self.baseEffect.texture2d0.name;
    glDeleteTextures(1, &textureName);
    self.delegate = nil;
    [EAGLContext setCurrentContext:nil];
 
}

- (void)loadOriginalImage:(UIImage *)image defaultTextureHeight:(CGFloat)defaultTextureHeight{
    
    self.strechHeight = 0;
    
    NSError *error;
    NSDictionary *optionDict = @{GLKTextureLoaderOriginBottomLeft:@(YES), GLKTextureLoaderApplyPremultiplication:@(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfData:UIImagePNGRepresentation(image) options:optionDict error:&error];
    if (error) {
        [RTHud showText:@"纹理加载失败" onWindow:false];
        return;
    }
    if (!self.baseEffect) {
        self.baseEffect = [[GLKBaseEffect alloc] init];
    }
    if (self.baseEffect.texture2d0.name != 0) {
        GLuint textureName = self.baseEffect.texture2d0.name;
        glDeleteTextures(1, &textureName);
    }
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.enabled = GL_TRUE;

    CGFloat imageRatio = image.size.height / image.size.width;
    CGFloat imageHeight = self.bounds.size.height * defaultTextureHeight;
    CGFloat imageWidth = imageHeight / imageRatio;
    if (imageWidth > self.bounds.size.width) {
        imageWidth = self.bounds.size.width;
        imageHeight = imageWidth * imageRatio;
    }
    self.imageSize = image.size;
    self.textureWidth = imageWidth/self.bounds.size.width;
    self.textureHeight = imageHeight/self.bounds.size.height;
    
    [self updateVertexAndTextureWithStrechBeginY:kDefaultStrechBeginY
                                      strechEndY:kDefaultStrechEndY
                                    strechHeight:0
                                           apply:true];
   
    if (self.strechDelegate && [self.strechDelegate respondsToSelector:@selector(textureSizeDidChanged:strechBeginY:strechEndY:)]) {
        [self.strechDelegate textureSizeDidChanged:CGSizeMake(self.textureWidth, self.textureHeight)
                                      strechBeginY:self.strechTextureBeginY
                                        strechEndY:self.strechTextureEndY];
    }

    [self display];
}

- (void)updateVertexAndTextureWithStrechBeginY:(CGFloat)beginY
                                    strechEndY:(CGFloat)endY
                                  strechHeight:(CGFloat)strechHeight
                                         apply:(BOOL)apply
{

    CGFloat textureEdgeTop = (1 - self.textureHeight) * 0.5;
    CGFloat textureEdgeBottom = (1 + self.textureHeight) * 0.5;
    
    if (beginY < textureEdgeTop || endY > textureEdgeBottom || beginY > endY) {
        NSLog(@"检查传入值");
        return;
    }
    
    /* 通过改变顶点和纹理坐标来实现图片拉伸，即保证上下两个区域贴图大小不变，只改变拉伸区域高度
     * 示例 拉伸区域在图片上的坐标beginY = 0.25 endY = 0.75
     *
     * (0,1)        (1,1)
     *          上
     * (0,1-0.25)   (1,1-0.25)
     *          拉伸区域
     * (0,1-0.75)   (1,1-0.75)
     *          下
     * (0,0)        (1,0)
     */
    
    CGFloat textureBeginY = beginY - textureEdgeTop;
    CGFloat textureEndY = endY - textureEdgeTop;

    GLKVector3 pointLT = {-self.textureWidth, self.textureHeight + strechHeight, 0};
    GLKVector3 pointRT = {self.textureWidth, self.textureHeight + strechHeight, 0};
 
    GLKVector3 strechLT = {-self.textureWidth, self.textureHeight + strechHeight - 2*textureBeginY, 0};
    GLKVector3 strechRT = {self.textureWidth, self.textureHeight + strechHeight - 2*textureBeginY, 0};
    
    GLKVector3 strechLB = {-self.textureWidth, self.textureHeight - 2*textureEndY - strechHeight, 0};
    GLKVector3 strechLR = {self.textureWidth, self.textureHeight - 2*textureEndY - strechHeight, 0};
    
    GLKVector3 pointLB = {-self.textureWidth, -self.textureHeight - strechHeight, 0};
    GLKVector3 pointRB = {self.textureWidth, -self.textureHeight - strechHeight, 0};
    
    self.vertices[0].positionCoord = pointRT;
    self.vertices[0].textureCoord = GLKVector2Make(1, 1);
    self.vertices[1].positionCoord = pointLT;
    self.vertices[1].textureCoord = GLKVector2Make(0, 1);
    
    self.vertices[2].positionCoord = strechRT;
    self.vertices[2].textureCoord = GLKVector2Make(1, 1.0 - textureBeginY/self.textureHeight);
    
    self.vertices[3].positionCoord = strechLT;
    self.vertices[3].textureCoord = GLKVector2Make(0, 1.0 - textureBeginY/self.textureHeight);

    self.vertices[4].positionCoord = strechLR;
    self.vertices[4].textureCoord = GLKVector2Make(1, 1.0 - textureEndY/self.textureHeight);
    
    self.vertices[5].positionCoord = strechLB;
    self.vertices[5].textureCoord = GLKVector2Make(0, 1.0 - textureEndY/self.textureHeight);
 
    self.vertices[6].positionCoord = pointRB;
    self.vertices[6].textureCoord = GLKVector2Make(1, 0);
    
    self.vertices[7].positionCoord = pointLB;
    self.vertices[7].textureCoord = GLKVector2Make(0, 0);
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(RTStrechVertics) * 8, self.vertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(RTStrechVertics), NULL + offsetof(RTStrechVertics, positionCoord));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(RTStrechVertics), NULL + offsetof(RTStrechVertics, textureCoord));

    if (apply) {
        self.strechTextureBeginY = beginY - strechHeight * 0.5;
        self.strechTextureEndY =  endY + strechHeight * 0.5;
        self.textureHeight += strechHeight;
    }

}

- (void)strechWithValue:(CGFloat)value{
    CGFloat deltaHeight = value;
    if (value >= 0) {
        deltaHeight = MIN(deltaHeight, 1 - self.textureHeight);
    } else {
        deltaHeight = MAX(deltaHeight, self.strechTextureBeginY - self.strechTextureEndY);
    }
    
    self.strechHeight = deltaHeight;
    [self updateVertexAndTextureWithStrechBeginY:self.strechTextureBeginY
                                      strechEndY:self.strechTextureEndY
                                    strechHeight:self.strechHeight
                                           apply:false];
    
    if (self.strechDelegate && [self.strechDelegate respondsToSelector:@selector(textureSizeDidChanged:strechBeginY:strechEndY:)]) {
        
        CGFloat newBeginY = self.strechTextureBeginY - deltaHeight * 0.5;
        CGFloat newEndY = self.strechTextureEndY + deltaHeight * 0.5;
     
        [self.strechDelegate textureSizeDidChanged:CGSizeMake(self.textureWidth, self.textureHeight + deltaHeight)
                                      strechBeginY:newBeginY
                                        strechEndY:newEndY];
    }
    
    [self display];
}

- (void)makeEffectAsTextureIfNeed{
    if (self.strechHeight) {
        
        GLuint texture = [self createNewTextureFromCurrentTexture:self.baseEffect.texture2d0.name
                                                     textureWidth:self.textureWidth
                                                    textureHeight:self.textureHeight
                                                     strechBeginY:self.strechTextureBeginY
                                                       strechEndY:self.strechTextureEndY
                                                     strechHeight:self.strechHeight
                                                    processAction:NULL];
        
        self.textureHeight += self.strechHeight;
        self.strechTextureBeginY -= self.strechHeight*0.5;
        self.strechTextureEndY += self.strechHeight*0.5;
        self.imageSize = CGSizeMake(self.imageSize.width, self.imageSize.height * (1 + self.strechHeight/self.textureHeight));
        self.strechHeight = 0;
        
        if (self.strechDelegate && [self.strechDelegate respondsToSelector:@selector(didTextureSyncFinished)]) {
            [self.strechDelegate didTextureSyncFinished];
        }
        
        //替换新的纹理
        if (self.baseEffect.texture2d0.name != 0) {
            GLuint textureName = self.baseEffect.texture2d0.name;
            glDeleteTextures(1, &textureName);
        }
        self.baseEffect.texture2d0.name = texture;
                
//        self.tmpTexture = texture;
//        self.tmpFrameBuffer = frameBuffer;
    }
}

- (UIImage *)getEffectImage{
    
    __block UIImage *effectImage = nil;
    
    __weak typeof(self)weakSelf = self;
    [self createNewTextureFromCurrentTexture:self.baseEffect.texture2d0.name
                                textureWidth:self.textureWidth
                               textureHeight:self.textureHeight
                                strechBeginY:self.strechTextureBeginY
                                  strechEndY:self.strechTextureEndY
                                strechHeight:self.strechHeight
                               processAction:^(GLuint frameBuffer, CGFloat imageHeight) {
        GLsizei width = (GLsizei)weakSelf.imageSize.width;
        GLsizei height = (GLsizei)weakSelf.imageSize.height * (1 + weakSelf.strechHeight/weakSelf.textureHeight);
        size_t size = width * height * 4;
        GLubyte *buffer = malloc(size);
        glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
        CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, buffer, size, NULL);
//        size_t bitsPerComponent = 8;
//        size_t bitsPerPixel = 8 * 4;
//        size_t bytesPerRow = width * 4;
//        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
//        bool shouldInterpolate = NO; //抗锯齿
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGImageRef imageRef = CGImageCreate(width, height, 8, 32, width*4, colorSpaceRef, kCGBitmapByteOrderDefault, providerRef, NULL, NO, kCGRenderingIntentDefault);
        CGColorSpaceRelease(colorSpaceRef);
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        effectImage = UIGraphicsGetImageFromCurrentImageContext();
        free(buffer);
        CGDataProviderRelease(providerRef);
        CGImageRelease(imageRef);
        CGContextRelease(context);
    }];
    
    return effectImage;
    
}


#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClear(GL_COLOR_BUFFER_BIT);

    glBindTexture(GL_TEXTURE_2D, self.baseEffect.texture2d0.name);
    
    [self.baseEffect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 8);
    
}

#pragma mark - Private

/**
 * 根据当前纹理 进行拉伸创建一个新的纹理
 */
-(GLuint)createNewTextureFromCurrentTexture:(GLuint)currentTexture
                               textureWidth:(CGFloat)textureWidth
                              textureHeight:(CGFloat)textureHeight
                               strechBeginY:(CGFloat)strechBeginY
                                 strechEndY:(CGFloat)strechEndY
                               strechHeight:(CGFloat)strechHeight
                              processAction:(void(^)(GLuint , CGFloat))action
{
    
    CGFloat newImageHeight = self.imageSize.height * (1 + strechHeight/textureHeight);
    
      
    CGFloat newTextureHeight = textureHeight + strechHeight;
    CGFloat newStrechBeginY = strechBeginY - 0.5 * strechHeight;
    CGFloat newStrechEndY = strechEndY + 0.5 * strechHeight;
    
    //将顶点转换到新的坐标范围
    CGFloat textureTopY = (strechBeginY - (1 - textureHeight) * 0.5)/textureHeight;
    CGFloat textureBottomY = (strechEndY - (1 - textureHeight) * 0.5)/textureHeight;
    CGFloat vertexTopY = (newStrechBeginY - (1 - newTextureHeight) * 0.5) / newTextureHeight;
    CGFloat vertexBottomY = (newStrechEndY - (1 - newTextureHeight) * 0.5) / newTextureHeight;
    
    
    RTStrechVertics *vertices = malloc(sizeof(RTStrechVertics) * 8);
    vertices[0] = (RTStrechVertics){{-1, 1, 0}, {0, 1}};
    vertices[1] = (RTStrechVertics){{1, 1, 0}, {1, 1}};
    vertices[2] = (RTStrechVertics){{-1, 1-2*vertexTopY, 0}, {0, 1 - textureTopY}};
    vertices[3] = (RTStrechVertics){{1, 1-2*vertexTopY, 0}, {1, 1 - textureTopY}};
    vertices[4] = (RTStrechVertics){{-1, 1-2*vertexBottomY, 0}, {0, 1 - textureBottomY}};
    vertices[5] = (RTStrechVertics){{1, 1-2*vertexBottomY, 0}, {1, 1 - textureBottomY}};
    vertices[6] = (RTStrechVertics){{-1, -1, 0}, {0, 0}};
    vertices[7] = (RTStrechVertics){{1, -1, 0}, {1, 0}};
    //顶点缓存区
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(RTStrechVertics) * 8, vertices, GL_STATIC_DRAW);

    //帧缓存区 根据结果重新创建纹理
    GLuint frameBuffer, texture;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);

    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.imageSize.width, newImageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    //将纹理附着到帧缓存 渲染出一张纹理图
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
    glViewport(0, 0, self.imageSize.width, newImageHeight);

    //初始化程序 初始前先创建好缓存区
    GLuint program = [self useProgramWithShaderName:@"Normal"];
    //激活纹理 将旧纹理传进去
    GLuint textureSlot = glGetUniformLocation(program, "Texture");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, currentTexture);

    //An Open GL ES error breakpoint will be encountered if I
    //use glUniform1f when I reload texture info by GLKTextureLoader.
    //line 53 -- GLKTextureLoaderGLErrorKey=1282, GLKTextureLoaderErrorKey=OpenGLES Error
    glUniform1i(textureSlot, 0);
    GLuint positionSlot = glGetAttribLocation(program, "Position");
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(RTStrechVertics), NULL + offsetof(RTStrechVertics, positionCoord));
    GLuint textureCoordinateSlot = glGetAttribLocation(program, "textureCoordinate");
    glEnableVertexAttribArray(textureCoordinateSlot);
    glVertexAttribPointer(textureCoordinateSlot, 2, GL_FLOAT, GL_FALSE, sizeof(RTStrechVertics), NULL + offsetof(RTStrechVertics, textureCoord));
    GLuint polaroidSlot = glGetAttribLocation(program, "Polaroid");
    if (polaroidSlot != UINT32_MAX) {
      glVertexAttrib1f(polaroidSlot, 0);
    }

    //绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 8);
    
    !action?:action(frameBuffer, newImageHeight);
    

    //解除绑定帧缓存区的纹理
    glDeleteBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    free(vertices);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glDeleteFramebuffers(1, &frameBuffer);
    
    glDeleteProgram(program);
  
    
    return texture;
}


-(GLuint)useProgramWithShaderName:(NSString *)shaderName{
  
    GLuint program = glCreateProgram();
    
    GLuint vShader = [self complieShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fShader = [self complieShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    glAttachShader(program, vShader);
    glAttachShader(program, fShader);
    
    glLinkProgram(program);
    
    GLint linkResult;
    glGetProgramiv(program, GL_LINK_STATUS, &linkResult);
    if (linkResult == GL_FALSE) {
        NSAssert(NO, @"链接Program出错");
    }
    glUseProgram(program);
        
    return program;
    
}

-(GLuint)complieShaderWithName:(NSString *)shaderName type:(GLenum)type{
    
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
