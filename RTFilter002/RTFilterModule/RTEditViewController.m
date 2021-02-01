//
//  RTEditViewController.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import "RTEditViewController.h"
#import "RTEditGLTool.h"
@interface RTEditViewController ()
@property (nonatomic, strong) RTEditGLTool *glTool;
@property (nonatomic, strong) CAEAGLLayer *imageLayer;

@property (nonatomic, weak) UISlider *slider;
@property (nonatomic, weak) UISegmentedControl *segmentControl;

@end

@implementation RTEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    CAEAGLLayer *layer = [CAEAGLLayer layer];
    layer.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 288);
    layer.contentsScale = [UIScreen mainScreen].scale;
    [self.view.layer addSublayer:layer];
  
    
   
    
    [self.glTool setOriginalImage:self.image onLayer:layer];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height - 100, self.view.frame.size.width - 60, 40)];
    [self.view addSubview:slider];
    self.slider = slider;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:self.segmentTitles];
    segmentControl.frame = CGRectMake(slider.frame.origin.x, slider.frame.origin.y - 50, slider.frame.size.width, 40);
    [segmentControl addTarget:self action:@selector(segmentModeChanged:) forControlEvents:UIControlEventValueChanged];
    segmentControl.selectedSegmentIndex = 0;
    [self.view addSubview:segmentControl];
    self.segmentControl = segmentControl;
    
    [self segmentModeChanged:segmentControl];
    
    if (self.isActive) {
        [self.glTool startAnimation];
    }
    
}

-(void)sliderValueChanged:(UISlider *)sender{
     
    [self.glTool setPolaroidEffectValue:sender.value];
    
    [self.glTool render];
}

- (void)segmentModeChanged:(UISegmentedControl *)sender{
  
    [self.glTool setupProgramWithShaderName:self.shaderNames[sender.selectedSegmentIndex]];
    [self.glTool setPolaroidEffectValue:self.slider.value];
    [self.glTool render];
}


- (void)dealloc
{
    [self.glTool clear];
}
#pragma mark - getter
- (RTEditGLTool *)glTool{
    if (!_glTool) {
        _glTool = [RTEditGLTool shareInstance];
    }
    return _glTool;
}

@end
