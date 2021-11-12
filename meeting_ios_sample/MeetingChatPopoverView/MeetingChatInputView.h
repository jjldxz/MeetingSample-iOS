//
//  MeetingChatInputView.h
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/1.
//

#import <UIKit/UIKit.h>
#import "RoomUserInfoModel.h"

NS_ASSUME_NONNULL_BEGIN
@class MeetingChatInputView;
@protocol MeetingChatInputViewDelegate <NSObject>

- (void)meetingChatInputView:(MeetingChatInputView *)inputView DidFinishedEdit:(NSString *)text UserInfo:(RoomUserInfoModel *)userInfo;

- (void)meetingChatInputViewNeedClose:(MeetingChatInputView *)inputView;

- (void)meetingChatInputViewChoseUserList:(MeetingChatInputView *)inputView;
@end

@interface MeetingChatInputView : UIView
@property (strong, nonatomic) UITextField *inputText;
@property (weak, nonatomic) id<MeetingChatInputViewDelegate> delegate;
@property (strong, nonatomic) RoomUserInfoModel *sendUserInfo;//未空时发送的是全部，不为空时发送的是个人
@end

NS_ASSUME_NONNULL_END
