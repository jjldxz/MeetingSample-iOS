//
//  DrawShapeControlInfoModel.h
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/27.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawLineControlInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DrawShapeControlInfoModel : NSObject

@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, assign) BOOL finish;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, copy) NSString *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, copy) NSNumber *pageId;
@property (nonatomic, copy) DrawPointModel *endDot;
@property (nonatomic, assign) long time;
@property (nonatomic, copy) DrawPointModel *startDot;
@property (nonatomic, assign) CGFloat r;
@property (nonatomic, copy) DrawPointModel *sideLength;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) CGFloat textW;
@property (nonatomic, assign) CGFloat textH;
@property (nonatomic, copy) NSArray<DrawPointModel *> *points;

+ (instancetype)sendShapeRTMMessageModelWithType:(NSString *)type
                                         groupId:(NSNumber *)groupId
                                       lineColor:(NSString *)color
                                       lineWidth:(CGFloat)lineWidth;

@end

NS_ASSUME_NONNULL_END
