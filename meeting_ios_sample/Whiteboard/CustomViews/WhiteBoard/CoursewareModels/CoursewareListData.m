//
//  CoursewareListData.m
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/31.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "CoursewareListData.h"

@implementation CoursewareDetailInfoModel

- (id)copyWithZone:(NSZone *)zone {
    CoursewareDetailInfoModel *infoModel = [CoursewareDetailInfoModel new];
    infoModel.cos_path = self.cos_path.copy;
    infoModel.width = self.width.copy;
    infoModel.height = self.height.copy;
    return infoModel;
}

@end

@implementation CoursewareListData

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"pic_list" : CoursewareDetailInfoModel.class};
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"Id" : @"id", @"is_delete" : @"delete"};
}

@end
