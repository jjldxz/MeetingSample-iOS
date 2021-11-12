//
//  MeetingMenuHeaderBarView.h
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/3/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MeetingMenuHeaderBarViewDelegate <NSObject>

- (void)meetingMenuHeaderNeedJumpToSetingPage;

- (void)meetingMenuHeaderNeedClose;

@end

@interface MeetingMenuHeaderBarView : UIView

@property (weak, nonatomic) id<MeetingMenuHeaderBarViewDelegate> delegate;
@property (strong, nonatomic) UILabel *titleLabel;
- (void)changeCurrentMeetingRoomMemberCount:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
