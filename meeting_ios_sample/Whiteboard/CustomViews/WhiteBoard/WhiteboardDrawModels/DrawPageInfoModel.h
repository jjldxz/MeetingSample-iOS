//
//  DrawPageInfoModel.h
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/30.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawPageInfoModel : NSObject<NSCopying>

@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, copy) NSNumber *Id;

@end

NS_ASSUME_NONNULL_END
