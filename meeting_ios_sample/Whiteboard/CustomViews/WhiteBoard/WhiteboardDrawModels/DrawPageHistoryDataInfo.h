//
//  DrawPageHistoryDataInfo.h
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/31.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawShapeControlInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DrawPageHistoryRevokeInfo : NSObject

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, copy) NSNumber *time;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSArray<DrawShapeControlInfoModel *> *session;

@end

@interface DrawPageDetailInfo : NSObject

@property (nonatomic, copy) NSArray *data;
@property (nonatomic, copy) NSNumber *pageId;
@property (nonatomic, copy) NSString *pageUrl;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSArray<DrawPageHistoryRevokeInfo *> *revokes;

@end

@interface DrawPageHistoryDataInfo : NSObject

@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *roomId;
@property (nonatomic, copy) NSString *updateType;
@property (nonatomic, copy) NSString *groupState;
@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, copy) NSArray<DrawPageDetailInfo *> *pages;
@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, copy) NSArray *revoke;

@end

NS_ASSUME_NONNULL_END
