//
//  RTPresent.h
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *segmentTitles;
@property (nonatomic, copy) NSArray *shaderNames;
@property (nonatomic, assign) BOOL isActive;

@property (nonatomic, copy) NSString *className;
@end

@interface RTPresent : NSObject
@property (nonatomic, strong) NSMutableArray    *dataArray;

- (void)loadData;
@end

NS_ASSUME_NONNULL_END
