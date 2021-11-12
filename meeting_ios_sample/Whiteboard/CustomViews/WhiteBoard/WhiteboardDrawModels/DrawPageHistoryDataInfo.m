//
//  DrawPageHistoryDataInfo.m
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/31.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "DrawPageHistoryDataInfo.h"
#import <YYKit/YYKit.h>

@implementation DrawPageHistoryRevokeInfo

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"Id" : @"id"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSMutableArray *drawPages = [NSMutableArray arrayWithCapacity:self.session.count];
    [self.session enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *jsonString = (NSString *)obj;
        id json = [jsonString jsonValueDecoded];
        DrawShapeControlInfoModel *model = [DrawShapeControlInfoModel modelWithJSON:json];
        [drawPages addObject:model];
    }];
    self.session = [drawPages copy];
    return YES;
}

@end

@implementation DrawPageDetailInfo

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSMutableArray *drawPages = [NSMutableArray arrayWithCapacity:self.data.count];
    [self.data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *jsonString = (NSString *)obj;
        id json = [jsonString jsonValueDecoded];
        DrawShapeControlInfoModel *model = [DrawShapeControlInfoModel modelWithJSON:json];
        [drawPages addObject:model];
    }];
    self.data = [drawPages copy];
    return YES;
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"revokes" : DrawPageHistoryRevokeInfo.class};
}

@end

@implementation DrawPageHistoryDataInfo

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"pages" : DrawPageDetailInfo.class};
}

@end
