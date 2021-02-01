//
//  RTPresent.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import "RTPresent.h"

@implementation RTModel

@end

@implementation RTPresent

- (void)loadData{
    
    [self.dataArray removeAllObjects];
    
    RTModel *model = [[RTModel alloc] init];
    model.title = @"分屏滤镜";
    model.segmentTitles = @[@"无",@"二分屏",@"三分屏",@"四分屏",@"六分屏",@"九分屏"];
    model.shaderNames = @[@"Normal",@"SplitScreen2",@"SplitScreen3",@"SplitScreen4",@"SplitScreen6",@"SplitScreen9"];
    [self.dataArray addObject:model];
    
    RTModel *model2 = [[RTModel alloc] init];
    model2.title = @"色彩滤镜";
    model2.segmentTitles = @[@"无",@"灰度",@"负片"];
    model2.shaderNames = @[@"Normal",@"Gray",@"Negative"];
    [self.dataArray addObject:model2];
    
    RTModel *model3 = [[RTModel alloc] init];
    model3.title = @"马赛克滤镜";
    model3.segmentTitles = @[@"无",@"马赛克4",@"马赛克6",@"马赛克3"];
    model3.shaderNames = @[@"Normal",@"Mosaic4",@"Mosaic6",@"Mosaic3"];
    [self.dataArray addObject:model3];
    

    
    RTModel *model4 = [[RTModel alloc] init];
    model4.title = @"动效滤镜";
    model4.segmentTitles = @[@"缩放",@"闪屏",@"灵魂出窍",@"抖动",@"毛刺",@"幻觉"];
    model4.shaderNames = @[@"Scale",@"Sparkle",@"SoulOut",@"ScaleMove",@"Glitch",@"Vertigo"];
    model4.isActive = true;
    [self.dataArray addObject:model4];
    
    RTModel *model5 = [[RTModel alloc] init];
    model5.title = @"大长腿";
    model5.className = @"RTStrechViewController";
    [self.dataArray addObject:model5];
    
}


#pragma mark - lazy

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataArray;
}
@end
