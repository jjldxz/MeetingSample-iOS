//
//  DrawPageInfoModel.m
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/30.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "DrawPageInfoModel.h"

@implementation DrawPageInfoModel

- (id)copyWithZone:(NSZone *)zone {
    DrawPageInfoModel *model = [DrawPageInfoModel new];
    model.Id = self.Id.copy;
    model.kind = self.kind.copy;
    model.type = self.type.copy;
    model.groupId = self.groupId.copy;
    model.groupName = self.groupName.copy;
    return model;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"Id" : @"id"};
}

@end
