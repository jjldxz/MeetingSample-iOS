//
//  DXZEducationRevokeInfoModel.m
//  DXZLvbSDK
//
//  Created by FoxDog on 2020/5/30.
//  Copyright © 2020 jinjilie. All rights reserved.
//

#import "DXZEducationRevokeInfoModel.h"
#import <YYKit/YYKit.h>

@implementation DXZEducationRevokeInfoModel

- (instancetype)initWithLocalRevokeViews:(NSArray<CALayer*> *)views {
    self = [super init];
    if (self) {
        self.Id = [NSString stringWithUUID];
        self.drawViews = views;
    }
    return self;
}

@end
