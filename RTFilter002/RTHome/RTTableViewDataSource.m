//
//  RTTableViewDataSource.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import "RTTableViewDataSource.h"


@implementation RTTableViewCell
+ (NSString *)reuseID {
    return NSStringFromClass([self class]);
}

@end

@interface RTTableViewDataSource ()
@property (nonatomic, strong) NSString *reuseID;
@property (nonatomic, copy) PreConfigBlock configBlock;
@property (nonatomic, copy) ClickBlock clickBlock;
@end

@implementation RTTableViewDataSource

- (instancetype)initWithCellIdentifier:(NSString *)reuseID preConfig:(nonnull PreConfigBlock)cellConfig click:(nonnull ClickBlock)clickBlock{
    if (self = [super init]) {
        self.reuseID = reuseID;
        self.configBlock = cellConfig;
        self.clickBlock = clickBlock;
    }
    return self;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseID];
    
    if (self.configBlock) {
        self.configBlock(cell,self.dataArray[indexPath.row], indexPath);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    !self.clickBlock?:self.clickBlock(self.dataArray[indexPath.row],indexPath);
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
