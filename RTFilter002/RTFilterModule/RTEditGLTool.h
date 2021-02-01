//
//  RTEditGLTool.h
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RTEditGLTool : NSObject

+ (instancetype)shareInstance;

- (void)setOriginalImage:(UIImage *)originalImage onLayer:(CAEAGLLayer *)layer;

- (void)setupProgramWithShaderName:(NSString *)shaderName;

- (void)setPolaroidEffectValue:(CGFloat)value;


- (void)render;

- (void)startAnimation;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
