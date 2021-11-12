//
//  MeetingChatPopoverView.h
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/12.
//

#import <UIKit/UIKit.h>
#import "MeetingChatMessageDataModel.h"
#import "MeetingChatBaseView.h"

NS_ASSUME_NONNULL_BEGIN
@class MeetingChatPopoverView;
@protocol MeetingChatPopoverViewDelegate <NSObject>

- (MeetingChatMessageDataModel *)meetingChatPopoverView:(MeetingChatPopoverView *)chatPopView UserDidInputChatMessage:(NSString *)text userId:(NSNumber *)userId;
- (void)meetingChatPopoverViewChoseUserList:(MeetingChatPopoverView *)chatPopView;
@end

@interface MeetingChatPopoverView : UIView

@property (strong, nonatomic, readonly) MeetingChatBaseView *chatView;
@property (weak, nonatomic) id<MeetingChatPopoverViewDelegate> delegate;

- (void)animationPopUpView;

- (void)animationPopOverView;

@end

NS_ASSUME_NONNULL_END
