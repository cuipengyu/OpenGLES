//
//  RTTableViewDataSource.h
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


@interface RTTableViewCell : UITableViewCell
@property (nonatomic, strong) NSIndexPath *indexPath;

+ (NSString *)reuseID;

@end

typedef void(^PreConfigBlock)(UITableViewCell *cell, id model, NSIndexPath *indexPath);
typedef void(^ClickBlock)(id model,NSIndexPath *indexPath);
@interface RTTableViewDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithCellIdentifier:(NSString *)reuseID preConfig:(PreConfigBlock)cellConfig click:(ClickBlock)clickBlock;

@property (nonatomic, strong)  NSMutableArray *dataArray;


@end

NS_ASSUME_NONNULL_END
