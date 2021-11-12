//
//  DrawLineControlInfoModel.h
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/27.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawPointModel : NSObject<NSCopying>

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

@end

@interface DrawLineControlInfoModel : NSObject

@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, assign) BOOL finish;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, copy) NSNumber *pageId;
@property (nonatomic, copy) NSArray<DrawPointModel *> *points;
@property (nonatomic, assign) long time;

+ (instancetype)sendRTMPointInfoWithGroupId:(NSNumber *)groupId
                                     PageId:(NSNumber *)pageId
                                  LineColor:(NSString *)color
                              StartPointSit:(CGPoint)point
                                   DrawType:(NSString *)drawType;

@end

NS_ASSUME_NONNULL_END
