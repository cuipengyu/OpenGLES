//
//  UIImage+RTExt.h
//  RTFilter002
//
//  Created by CuiPengyu on 2021/2/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (RTExt)
- (instancetype)fixImageOrientation;
-(UIImage *)scaleToMaxSize:(CGFloat)maxSize;
@end

NS_ASSUME_NONNULL_END
