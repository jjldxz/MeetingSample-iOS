//
//  RoomUserInfoModel.h
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomUserInfoModel : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *role;
@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) NSInteger user_ext_id;
@property (assign, nonatomic) BOOL hand;
@property (assign, nonatomic) BOOL audio;
@property (assign, nonatomic) BOOL video;
@property (copy, nonatomic) NSString *share;
@property (copy, nonatomic) NSString *groupId;

@end

NS_ASSUME_NONNULL_END
