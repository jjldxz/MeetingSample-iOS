//
//  DrawPageRevokeInfoModel.h
//  DXZLVBLib
//
//  Created by FoxDog on 2020/4/24.
//  Copyright © 2020 DXZVideoGroup. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawPageRevokeInfoModel : NSObject

@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, copy) NSNumber *pageId;
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
