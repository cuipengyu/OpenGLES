//
//  AppDelegate.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import "AppDelegate.h"
#import "RTHomeViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    RTHomeViewController *homeVC = [[RTHomeViewController alloc] init];
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    self.window.rootViewController = rootVC;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}




@end
