//
//  WhiteboardMessageInfoModel.m
//  DXZLVBLib
//
//  Created by FoxDog on 2020/4/24.
//  Copyright © 2020 DXZVideoGroup. All rights reserved.
//

#import "WhiteboardMessageInfoModel.h"

@implementation WhiteboardMessageInfoModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"Id" : @"id"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.typeEnum = dxzLvbWBDrwTypeTansform(self.type);
    return YES;
}

@end
