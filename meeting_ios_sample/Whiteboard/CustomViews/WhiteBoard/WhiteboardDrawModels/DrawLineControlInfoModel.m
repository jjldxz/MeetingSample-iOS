//
//  DrawLineControlInfoModel.m
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/27.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "DrawLineControlInfoModel.h"


@implementation DrawPointModel

- (id)copyWithZone:(NSZone *)zone {
    DrawPointModel *model = [DrawPointModel new];
    model.x = self.x;
    model.y = self.y;
    return model;
}

@end

@implementation DrawLineControlInfoModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"Id" : @"id"};
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"points" : DrawPointModel.class};
}

+ (instancetype)sendRTMPointInfoWithGroupId:(NSNumber *)groupId
                                     PageId:(NSNumber *)pageId
                                  LineColor:(NSString *)color
                              StartPointSit:(CGPoint)point
                                   DrawType:(NSString *)drawType {
    DrawLineControlInfoModel *model = [DrawLineControlInfoModel new];
    model.kind = @"msg_drawing";
    model.type = drawType;
    model.finish = false;
    model.groupId = groupId;
    model.pageId = pageId;
    model.lineWidth = 4;
    model.lineColor = color;
    DrawPointModel *pointModel = [DrawPointModel new];
    pointModel.x = point.x;
    pointModel.y = point.y;
    model.points = @[pointModel];
    return model;
}

@end
