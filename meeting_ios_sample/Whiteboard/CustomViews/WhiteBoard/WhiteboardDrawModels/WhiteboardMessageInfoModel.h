//
//  WhiteboardMessageInfoModel.h
//  DXZLVBLib
//
//  Created by FoxDog on 2020/4/24.
//  Copyright © 2020 DXZVideoGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhiteboardToolsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WhiteboardMessageInfoModel : NSObject

@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, copy) NSNumber *Id;
@property (nonatomic, assign) DXZLvbWhiteboardTypeEnum typeEnum;

@end

NS_ASSUME_NONNULL_END
