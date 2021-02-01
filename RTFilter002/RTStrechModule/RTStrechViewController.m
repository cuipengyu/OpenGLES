//
//  RTStrechViewController.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/28.
//

#import "RTStrechViewController.h"
#import "RTStrechResultView.h"

@interface RTStrechViewController ()<RTStrechViewDelegate>{
    BOOL isLoaded;
}
@property (nonatomic, weak) RTStrechResultView *resultView;
@property (nonatomic, weak) UISlider *slider;
@property (nonatomic, weak) UIView *topControl;
@property (nonatomic, weak) UIView *bottomControl;
@property (nonatomic, weak) UIView *maskView;

@property (nonatomic, assign) CGSize textureSize;//(0~1.0,0~1.0)
@property (nonatomic, assign) CGFloat topButtonCenterY;
@property (nonatomic, assign) CGFloat bottomButtonCenterY;
@end

@implementation RTStrechViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addSubViews];

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!isLoaded) {
        isLoaded = true;
        [self.resultView loadOriginalImage:self.image defaultTextureHeight:0.7];
    }
}

- (void)dealloc{
    [self.resultView removeFromSuperview];
    self.resultView = nil;
}
 


-(void)addSubViews{
    
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = -0.1;
    slider.maximumValue = 0.1;
    slider.value = 0;
    slider.minimumTrackTintColor = slider.maximumTrackTintColor = [UIColor redColor];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    self.slider = slider;
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).offset(-100);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop).offset(-40);
        make.height.offset(44);
    }];
    
    
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(slider.mas_left).offset(-5);
        make.centerY.equalTo(slider);
    }];
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(slider.mas_right).offset(5);
        make.centerY.equalTo(slider);
    }];
    
    
    RTStrechResultView *resultView = [[RTStrechResultView alloc] init];
    [self.view addSubview:resultView];
    [resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.slider.mas_top).offset(-30);
    }];
    self.resultView = resultView;
    self.resultView.strechDelegate = self;
  
    UIView *topControl = [self createControl];
    [self.resultView addSubview:topControl];

    [topControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resultView.mas_top).offset(self.topButtonCenterY);
        make.right.equalTo(self.resultView);
        make.width.height.offset(30);
    }];
    
    UIView *bottomControl = [self createControl];
    [self.resultView addSubview:bottomControl];
    [bottomControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resultView.mas_top).offset(self.bottomButtonCenterY);
        make.right.equalTo(self.resultView);
        make.width.height.offset(30);
    }];
    
    UIView *maskView = [[UIView alloc] init];
    maskView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [self.resultView addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.resultView);
        make.width.equalTo(self.resultView).offset(-30);
        make.top.equalTo(topControl.mas_centerY);
        make.bottom.equalTo(bottomControl.mas_centerY);
    }];
    
    self.topControl = topControl;
    self.bottomControl = bottomControl;
    
    UIPanGestureRecognizer *topPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topButtonPan:)];
    [topControl addGestureRecognizer:topPanGesture];
    UIPanGestureRecognizer *bottomPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(bottomButtonPan:)];
    [bottomControl addGestureRecognizer:bottomPanGesture];
}

- (UIView *)createControl{
    UIView * cView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    cView.backgroundColor = [UIColor redColor];
    cView.layer.cornerRadius = 15;
    return cView;
}

#pragma mark - Action

- (void)reset:(id)sender{
    [self.slider setValue:0];
 
    [self.resultView loadOriginalImage:self.image defaultTextureHeight:0.7];
}

- (void)save:(id)sender{
  
    __block BOOL isAuthed = false;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            isAuthed = true;
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if (!isAuthed) {
        [self showAlert:@"请允许我访问您的相册"];
        return;
    }
    
    UIImage *effectImage = [self.resultView getEffectImage];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:effectImage];
        NSLog(@"%@",request.placeholderForCreatedAsset.localIdentifier);
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"已保存到相册"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:[NSString stringWithFormat:@"保存失败 -- %@",error.domain]];
            });
        }
    }];
    NSLog(@"%@",effectImage);
}

- (void)showAlert:(NSString *)alertMessage{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertMessage message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
 
    [alertController addAction:cancelAction];
    [self.navigationController.topViewController presentViewController:alertController animated:true completion:NULL];
}

- (void)topButtonPan:(UIPanGestureRecognizer*)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.resultView makeEffectAsTextureIfNeed];
        self.topControl.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
    } else if(sender.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [sender translationInView:self.topControl];
        CGFloat newY = self.topButtonCenterY + translation.y;
        CGFloat minY = (1 - self.textureSize.height) / 2.0 * self.resultView.frame.size.height;
        newY = MAX(newY, minY);
        newY = MIN(newY, self.bottomButtonCenterY);
        self.topButtonCenterY = newY;
        [sender setTranslation:CGPointZero inView:self.topControl];
        [self.topControl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.resultView.mas_top).offset(self.topButtonCenterY);
        }];
        
        //归一化 以resultView高为1，算出拉伸起始y
        [self.resultView updateVertexAndTextureWithStrechBeginY:newY/self.resultView.frame.size.height
                                                     strechEndY:self.bottomButtonCenterY/self.resultView.frame.size.height
                                                   strechHeight:0
                                                          apply:true];
    } else {
        self.topControl.backgroundColor = [UIColor redColor];
    }
  
}
- (void)bottomButtonPan:(UIPanGestureRecognizer*)sender{
    
   
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.resultView makeEffectAsTextureIfNeed];
        self.bottomControl.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
    } else if(sender.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [sender translationInView:self.bottomControl];
        CGFloat newY = self.bottomButtonCenterY + translation.y;
        CGFloat maxY = (0.5 + 0.5 * self.textureSize.height) * self.resultView.frame.size.height;
        newY = MAX(newY, self.topButtonCenterY);
        newY = MIN(newY, maxY);
        self.bottomButtonCenterY = newY;
        [sender setTranslation:CGPointZero inView:self.bottomControl];
        [self.bottomControl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.resultView.mas_top).offset(self.bottomButtonCenterY);
        }];
        
        //归一化 以resultView高为1，算出拉伸起始y
        [self.resultView updateVertexAndTextureWithStrechBeginY:self.topButtonCenterY/self.resultView.frame.size.height
                                                     strechEndY:newY/self.resultView.frame.size.height
                                                   strechHeight:0
                                                          apply:true];
    } else {
        self.bottomControl.backgroundColor = [UIColor redColor];
    }
   
}

- (void)sliderValueChanged:(UISlider *)sender{
    
    [self.resultView strechWithValue:sender.value];
}

#pragma mark - RTStrechViewDelegate
- (void)textureSizeDidChanged:(CGSize)textureSize strechBeginY:(CGFloat)beginY strechEndY:(CGFloat)endY{
    self.textureSize = CGSizeMake(textureSize.width, textureSize.height);
    self.topButtonCenterY = beginY*self.resultView.frame.size.height;
    self.bottomButtonCenterY = endY*self.resultView.frame.size.height;
    [self.topControl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resultView.mas_top).offset(self.topButtonCenterY);
    }];
    [self.bottomControl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resultView.mas_top).offset(self.bottomButtonCenterY);
    }];
    
}
- (void)didTextureSyncFinished{
    [self.slider setValue:0];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

