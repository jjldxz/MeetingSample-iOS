//
//  DXZEducationRevokeInfoModel.h
//  DXZLvbSDK
//
//  Created by FoxDog on 2020/5/30.
//  Copyright © 2020 jinjilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface DXZEducationRevokeInfoModel : NSObject

@property (nonatomic, copy) NSArray<__kindof CALayer *> *drawViews;
@property (nonatomic, copy) NSString *Id;

- (instancetype)initWithLocalRevokeViews:(NSArray<__kindof CALayer *> *)views;

@end

NS_ASSUME_NONNULL_END
