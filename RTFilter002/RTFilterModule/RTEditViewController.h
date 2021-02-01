//
//  RTEditViewController.h
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTEditViewController : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray *segmentTitles;
@property (nonatomic, strong) NSArray *shaderNames;
@property (nonatomic, assign) BOOL isActive;
@end

NS_ASSUME_NONNULL_END
