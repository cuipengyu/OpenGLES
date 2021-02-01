//
//  RTPickerPhotoManager.h
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/28.
//  Copyright © 2020 CuiPengyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RTPickerPhotoManager : NSObject
@property (nonatomic, copy, nullable) void(^selectedPhotoBlock)(UIImage *image);
@property (nonatomic, strong, nullable) UIImage * lastSelectedImage;
+ (instancetype)shareManager;

- (void)showPickerFrom:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
