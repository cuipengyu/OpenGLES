//
//  RTHud.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/2/1.
//  Copyright © 2020 CuiPengyu. All rights reserved.
//

#import "RTHud.h"
#import <MBProgressHUD/MBProgressHUD.h>
@implementation RTHud

+ (UIWindow *)currentWindow
{
    return [UIApplication sharedApplication].keyWindow;
}

+ (UIView *)currentView
{
    UIViewController * vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController*)vc visibleViewController];
    }
    return vc.view;
}

+ (MBProgressHUD *)showText:(NSString *)text onWindow:(BOOL)onWindow{
    
  
    UIView *superView = onWindow ? [self currentWindow] : [self currentView];
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:superView];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:superView animated:true];
    }
    
    hud.mode = MBProgressHUDModeText;
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = text;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor blackColor];
    [hud hideAnimated:true afterDelay:2.f];
    
    return hud;
}

+ (MBProgressHUD *)showLoadingIsOnWindow:(BOOL)onWindow{
    return [self showLoadingIsOnWindow:onWindow text:@"正在加载..."];
}

+ (MBProgressHUD *)showLoadingIsOnWindow:(BOOL)onWindow text:(NSString *)text{
    UIView *superView = onWindow ? [self currentWindow] : [self currentView];
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:superView];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:superView animated:true];
    }
    hud.label.text = text;
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor blackColor];
    return hud;
}

+ (void)hidden{
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:[self currentWindow]];
    if (hud) {
        [hud hideAnimated:false];
    }
    
    MBProgressHUD *hud2 = [MBProgressHUD HUDForView:[self currentView]];
    if (hud2) {
        [hud2 hideAnimated:false];
    }
}
@end
