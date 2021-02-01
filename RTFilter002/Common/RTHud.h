//
//  RTHud.h
//  RTFilter002
//
//  Created by CuiPengyu on 2020/2/1.
//  Copyright © 2020 CuiPengyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBProgressHUD;

NS_ASSUME_NONNULL_BEGIN

@interface RTHud : NSObject

+ (MBProgressHUD *)showText:(NSString *)text onWindow:(BOOL)onWindow;

+ (MBProgressHUD *)showLoadingIsOnWindow:(BOOL)onWindow;

+ (MBProgressHUD *)showLoadingIsOnWindow:(BOOL)onWindow text:(NSString *)text;
+ (void)hidden;
@end

NS_ASSUME_NONNULL_END
