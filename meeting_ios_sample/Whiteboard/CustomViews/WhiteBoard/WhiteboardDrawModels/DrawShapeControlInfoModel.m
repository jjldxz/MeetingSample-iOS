//
//  DrawShapeControlInfoModel.m
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/27.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "DrawShapeControlInfoModel.h"
#import <UIKit/UIKit.h>

@implementation DrawShapeControlInfoModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"Id" : @"id"};
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"endDot" : DrawPointModel.class, @"startDot" : DrawPointModel.class, @"points" : DrawPointModel.class};
}

+ (instancetype)sendShapeRTMMessageModelWithType:(NSString *)type
                                         groupId:(NSNumber *)groupId
                                       lineColor:(NSString *)color
                                       lineWidth:(CGFloat)lineWidth {
    DrawShapeControlInfoModel *shapeInfoModel = [DrawShapeControlInfoModel new];
    shapeInfoModel.kind = @"msg_drawing";
    shapeInfoModel.groupId = groupId;
    shapeInfoModel.lineWidth = lineWidth;
    shapeInfoModel.lineColor = color;
    return shapeInfoModel;
}

@end
