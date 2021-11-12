//
//  MeetChatRoomView.h
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "MeetingChatMessageDataModel.h"
#import "MeetingChatInputView.h"
#import "BHXPikerView.h"

#define kDNavBarAndStatusBarHeight (CGFloat)(kStatusBarH + kBottomSafeH + 44.f)

NS_ASSUME_NONNULL_BEGIN
@class MeetChatRoomView;
@protocol MeetChatRoomViewDelegate <NSObject>
@optional
- (void)meetChatRoomView:(MeetChatRoomView *)chatRoom DidUserInputText:(NSString *)text userInfo:(RoomUserInfoModel *)userInfo;
- (void)meetChatRoomViewChoseUserList:(MeetChatRoomView *)chatRoom;
- (void)meetingMenuBaseViewClose;
@end

@interface MeetChatRoomView : UIView
@property (weak, nonatomic) id<MeetChatRoomViewDelegate> delegate;
@property (weak, nonatomic) id<MeetChatRoomViewDelegate> delegatee;
@property (strong, nonatomic) MeetingChatInputView *inputView;
@property (strong, nonatomic) RoomUserInfoModel *user_info;
- (void)addChatMessage:(MeetingChatMessageDataModel *)message_model;

@end

NS_ASSUME_NONNULL_END
