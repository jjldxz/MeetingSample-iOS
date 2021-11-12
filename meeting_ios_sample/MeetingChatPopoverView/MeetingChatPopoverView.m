//
//  MeetingChatPopoverView.m
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/12.
//

#import "MeetingChatPopoverView.h"


@interface MeetingChatPopoverView ()<MeetChatRoomViewDelegate, MeetingChatBaseViewDelegate>

@property (assign, nonatomic) UIDeviceOrientation orientation;
@property (strong, nonatomic, readwrite) MeetingChatBaseView *chatView;

@end

@implementation MeetingChatPopoverView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AppInterfaceOrientationMask:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.orientation = [UIDevice currentDevice].orientation;
        [self addSubview:self.chatView];
        
//        UITapGestureRecognizer *tapCancelAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animationPopOverView)];
//        [self addGestureRecognizer:tapCancelAction];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.orientation == UIDeviceOrientationPortrait) {
        _chatView.frame = CGRectMake(0, CHATPOPVIEWTOP, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CHATPOPVIEWTOP);
    } else if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        _chatView.frame = CGRectMake(CGRectGetWidth(self.frame) - MeetingMenuSliderWidth, 0, MeetingMenuSliderWidth, CGRectGetHeight(self.frame));
    } else {
        _chatView.frame = CGRectMake(0, CHATPOPVIEWTOP, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CHATPOPVIEWTOP);
    }
}

#pragma mark - 加载聊天数据
- (void)loadCurrentChatMessages:(MeetingChatMessageDataModel *)data {
    [_chatView.chatListView addChatMessage:data];
}

#pragma mark - 屏幕旋转通知
- (void)AppInterfaceOrientationMask:(NSNotification *)notification {
    UIDeviceOrientation currentOri = [UIDevice currentDevice].orientation;
    if (currentOri == UIDeviceOrientationPortrait || currentOri == UIDeviceOrientationLandscapeLeft || currentOri == UIDeviceOrientationLandscapeRight) {
        if (currentOri != self.orientation) {
            self.orientation = currentOri;
            [self setNeedsLayout];
        }
    }
}

#pragma mark - 弹出动画
- (void)animationPopUpView {
    self.hidden = NO;
    if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        self.frame = CGRectMake(kScreenHeight, 0, kScreenHeight, kScreenWidth);
        [UIView animateWithDuration:0.25 delay:0.f usingSpringWithDamping:0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
        [UIView animateWithDuration:0.25 delay:0.f usingSpringWithDamping:0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - 关闭动画
- (void)animationPopOverView {
    [self.chatView.chatListView.inputView.inputText endEditing:YES];
    if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        [UIView animateWithDuration:0.25 delay:0.f usingSpringWithDamping:0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(kScreenHeight, 0, kScreenHeight, kScreenWidth);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.25 delay:0.f usingSpringWithDamping:0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
}

#pragma mark - MeetChatRoomViewDelegate
- (void)meetChatRoomView:(MeetChatRoomView *)chatRoom DidUserInputText:(NSString *)text userInfo:(RoomUserInfoModel *)userInfo{
    if (text && ![text isEqualToString:@""]) {
        if (_delegate && [_delegate respondsToSelector:@selector(meetingChatPopoverView:UserDidInputChatMessage:userId:)]) {
            MeetingChatMessageDataModel *data = [_delegate meetingChatPopoverView:self UserDidInputChatMessage:text userId:@(userInfo.user_ext_id)];
            data.toUid = @(userInfo.user_ext_id).stringValue;
            data.toUser_name = userInfo.name;
            data.messageDate = [NSDate date];
            [chatRoom addChatMessage:data];
        }
    }
}

- (void)meetChatRoomViewChoseUserList:(MeetChatRoomView *)chatRoom{
    if (self.delegate && [self.delegate respondsToSelector:@selector(meetingChatPopoverViewChoseUserList:)]) {
        [self.delegate meetingChatPopoverViewChoseUserList:self];
    }
}

#pragma mark - MeetingChatBaseViewDelegate
- (void)meetingChatBaseViewNeedClose:(MeetingChatBaseView *)chatBaseView {
    self.hidden = YES;
}

#pragma mark - lazy load
- (MeetingChatBaseView *)chatView {
    if (_chatView == nil) {
        _chatView = [[MeetingChatBaseView alloc] initWithFrame:CGRectMake(0, CHATPOPVIEWTOP, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CHATPOPVIEWTOP)];
        _chatView.delegate = self;
        _chatView.chatListView.delegate = self;
    }
    return _chatView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}
@end
