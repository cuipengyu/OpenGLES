//
//  RTStrechResultView.h
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/28.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTStrechViewDelegate <NSObject>
@required
- (void)textureSizeDidChanged:(CGSize)textureSize strechBeginY:(CGFloat)beginY strechEndY:(CGFloat)endY;
- (void)didTextureSyncFinished;
@end

@interface RTStrechResultView : GLKView

@property (nonatomic, weak) id<RTStrechViewDelegate> strechDelegate;

/**
 * 加载一张图片 defaultTextureHeight在控件内的最大高度占比
 */
- (void)loadOriginalImage:(UIImage *)image defaultTextureHeight:(CGFloat)defaultTextureHeight;

/**
 * 更新拉伸区域  根据传入的归一化beginY、endY来更新顶点坐标 strechHeight拉伸值  apply=true表示后续在此基础上拉伸
 */
- (void)updateVertexAndTextureWithStrechBeginY:(CGFloat)beginY
                                    strechEndY:(CGFloat)endY
                                  strechHeight:(CGFloat)strechHeight
                                         apply:(BOOL)apply;

/**
 * 拉伸 value ∈ [ > defaultTextureHeight - 1,  < 1 - defaultTextureHeight] 默认为一次性做图
 */
- (void)strechWithValue:(CGFloat)value;

/**
 * 应用当前效果作为新的纹理图
 */
- (void)makeEffectAsTextureIfNeed;


- (UIImage *)getEffectImage;

@end

NS_ASSUME_NONNULL_END
