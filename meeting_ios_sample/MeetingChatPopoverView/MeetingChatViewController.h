//
//  MeetingChatViewController.h
//  meeting_iOS
//
//  Created by HYWD on 2021/8/11.
//

#import <UIKit/UIKit.h>
#import "MeetingChatMessageDataModel.h"
#import "MeetChatRoomView.h"

@class MeetingChatViewController;

NS_ASSUME_NONNULL_BEGIN
@protocol MeetingChatViewDelegate <NSObject>

- (MeetingChatMessageDataModel *)meetingChatPopoverView:(MeetingChatViewController *)chatPopView UserDidInputChatMessage:(NSString *)text userId:(NSNumber *)userId;
- (void)meetingChatPopoverViewChoseUserList:(MeetingChatViewController *)chatPopView;
@end

@interface MeetingChatViewController : UIViewController

@property (weak, nonatomic) id<MeetingChatViewDelegate> delegate;
@property (nonatomic,strong)MeetChatRoomView *chatView;

- (void)settingManager:(__weak id)manager;

- (void)settingCurrentUserInfoMap:(NSDictionary *)info_map;

- (void)receivedMeetingChatMessage:(MeetingChatMessageDataModel *)data;

@end

NS_ASSUME_NONNULL_END
