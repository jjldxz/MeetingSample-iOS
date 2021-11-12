//
//  MeetingChatMessageDataModel.h
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetingChatMessageDataModel : NSObject

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *user_name;
@property (copy, nonatomic) NSString *user_avatar;
@property (copy, nonatomic) NSString *_Nullable toUserId;
@property (copy, nonatomic) NSString *toUid;
@property (copy, nonatomic) NSString *_Nullable toUser_name;
@property (copy, nonatomic) NSString *toUser_avatar;
@property (copy, nonatomic) NSString *chat_message;
@property (assign, nonatomic) bool timeMessage;
@property (copy, nonatomic) NSString *nowTimeStr;
@property (strong, nonatomic) NSDate *messageDate;
@property (assign, nonatomic, readonly) CGSize text_size;

@end

NS_ASSUME_NONNULL_END
