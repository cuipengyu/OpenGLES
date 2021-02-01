//
//  RTPickerPhotoManager.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/28.
//  Copyright © 2020 CuiPengyu. All rights reserved.
//

#import "RTPickerPhotoManager.h"
#import "UIImage+RTExt.h"

@interface RTPickerPhotoManager ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) UIViewController *targetController;
@end

@implementation RTPickerPhotoManager

+ (instancetype)shareManager{
    static RTPickerPhotoManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [RTPickerPhotoManager new];
    });
    return _manager;
}

- (void)showPickerFrom:(UIViewController *)viewController {
    
    if (!viewController) {
        return;
    }
    self.targetController = viewController;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择图片来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(alertController)weakController = alertController;
    __weak typeof(self)weakSelf = self;
    UIAlertAction *tAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakController dismissViewControllerAnimated:true completion:NULL];
        [weakSelf takePhoto];
    }];
    [alertController addAction:tAction];
    
    UIAlertAction *lAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakController dismissViewControllerAnimated:true completion:NULL];
        [weakSelf selectPhoto];
    }];
    [alertController addAction:lAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakController dismissViewControllerAnimated:true completion:NULL];
    }];
    [alertController addAction:cancelAction];
    
    [self.targetController presentViewController:alertController animated:true completion:NULL];
}

- (void)takePhoto{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePickerController.delegate = self;
//    imagePickerController.allowsEditing = true;
    [self.targetController presentViewController:imagePickerController animated:true completion:NULL];
}

- (void)selectPhoto{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
//    imagePickerController.allowsEditing = true;
    [self.targetController presentViewController:imagePickerController animated:true completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [picker dismissViewControllerAnimated:true completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if (!image) {
        image = [UIImage new];
        NSLog(@"获取图片异常");
    }
    [RTHud showLoadingIsOnWindow:true];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.lastSelectedImage = [[image fixImageOrientation] scaleToMaxSize:4096];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [RTHud hidden];
            !self.selectedPhotoBlock?:self.selectedPhotoBlock(self.lastSelectedImage);
        });
        
    });
   
     
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.targetController dismissViewControllerAnimated:true completion:nil];
}

@end
