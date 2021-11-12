//
//  MeetingChatBaseView.h
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/12.
//

#import <UIKit/UIKit.h>
#import "MeetChatRoomView.h"
#import "BHXPikerView.h"

#define CHATPOPVIEWTOP     kStatusBarH
#define MeetingMenuSliderWidth   (350.f)

NS_ASSUME_NONNULL_BEGIN
@class MeetingChatBaseView;
@protocol MeetingChatBaseViewDelegate <NSObject>

- (void)meetingChatBaseViewNeedClose:(MeetingChatBaseView *)chatBaseView;

@end

@interface MeetingChatBaseView : UIView

@property (strong, nonatomic) MeetChatRoomView *chatListView;
@property (weak, nonatomic) id<MeetingChatBaseViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
