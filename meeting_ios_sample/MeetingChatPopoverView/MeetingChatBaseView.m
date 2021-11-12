//
//  MeetingChatBaseView.m
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/12.
//

#import "MeetingChatBaseView.h"
#import "MeetingMenuBaseTopView.h"
#import <YYKit/YYKit.h>

@interface MeetingChatBaseView ()<UIGestureRecognizerDelegate,MeetChatRoomViewDelegate>

@property (assign, nonatomic) UIDeviceOrientation orientation;
@property (strong, nonatomic) MeetingMenuBaseTopView *baseTopView;

@end

@implementation MeetingChatBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        self.orientation = [UIDevice currentDevice].orientation;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AppInterfaceOrientationMask:) name:UIDeviceOrientationDidChangeNotification object:nil];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        [self addSubview:self.baseTopView];
        [self addSubview:self.chatListView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.orientation == UIDeviceOrientationPortrait) {
        _baseTopView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 20.f);
        _chatListView.frame = CGRectMake(0, 20.f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 20.f);
    } else if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        _baseTopView.frame = CGRectMake(0, 0, 20, CGRectGetHeight(self.frame));
        _chatListView.frame = CGRectMake(20.f, 0.f, CGRectGetWidth(self.frame) - 20.f, CGRectGetHeight(self.frame));
    }
}

#pragma mark - 屏幕旋转通知
- (void)AppInterfaceOrientationMask:(NSNotification *)notification {
    UIDeviceOrientation currentOri = [UIDevice currentDevice].orientation;
    if (currentOri == UIDeviceOrientationPortrait || currentOri == UIDeviceOrientationLandscapeLeft || currentOri == UIDeviceOrientationLandscapeRight) {
        if (currentOri != self.orientation) {
            self.orientation = currentOri;
            [_baseTopView changeDeviceOrientation:currentOri];
            [self setNeedsLayout];
        }
    }
}

#pragma mark - 拖拽手势事件
- (void)panAction:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        [self commitTranslation:[sender translationInView:self]];
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        [self moveEndAndResetUI];
    }
}

- (void)commitTranslation:(CGPoint)translation {
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10)
        return;
    if (self.orientation == UIDeviceOrientationPortrait) {
        if (absY > absX) {
            [self calculatePortraitPanMoveDistance:translation.y];
        } else {
            return;
        }
    } else if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        if (absX > absY) {
            [self calculateLandscapePanMoveDistance:translation.x];
        }
    }
}

#pragma mark - 计算上下拖拽移动距离
- (void)calculatePortraitPanMoveDistance:(CGFloat)moveDistance {
    if (moveDistance < 0) {
        //向上滑动
        if (CGRectGetMinY(self.frame) <= CHATPOPVIEWTOP) {
            self.frame = CGRectMake(0, CHATPOPVIEWTOP, kScreenWidth, kScreenHeight - CHATPOPVIEWTOP);
        } else {
            self.frame = CGRectMake(0, CHATPOPVIEWTOP + moveDistance, kScreenWidth, kScreenHeight - CHATPOPVIEWTOP);
        }
    } else {
        //向下滑动
        self.frame = CGRectMake(0, CHATPOPVIEWTOP + moveDistance, kScreenWidth, kScreenHeight - CHATPOPVIEWTOP);
    }
}

#pragma mark - 计算左右拖拽移动距离
- (void)calculateLandscapePanMoveDistance:(CGFloat)moveDistance {
    if (moveDistance < 0) {
        //向左滑动
        if (CGRectGetWidth(self.frame) >= MeetingMenuSliderWidth) {
            self.frame = CGRectMake(kScreenHeight - MeetingMenuSliderWidth, 0, MeetingMenuSliderWidth, kScreenWidth);
        } else {
            self.frame = CGRectMake(kScreenHeight - MeetingMenuSliderWidth - moveDistance, 0, (CGRectGetWidth(self.frame) - moveDistance), kScreenWidth);
        }
    } else {
        //向右滑动
        self.frame = CGRectMake(kScreenHeight - MeetingMenuSliderWidth + moveDistance, 0, MeetingMenuSliderWidth, kScreenWidth);
    }
}

#pragma mark - 移动结束后调整UI
- (void)moveEndAndResetUI {
    if (self.orientation == UIDeviceOrientationPortrait) {
        if (CGRectGetMinY(self.frame) > CHATPOPVIEWTOP + 100.f) {
            [UIView animateWithDuration:0.25 delay:0.f usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight - CHATPOPVIEWTOP);
            } completion:^(BOOL finished) {
                // 页面移出
                if (self.delegate && [self.delegate respondsToSelector:@selector(meetingChatBaseViewNeedClose:)]) {
                    [self.delegate meetingChatBaseViewNeedClose:self];
                }
            }];
        } else {
            [UIView animateWithDuration:0.25 delay:0.f usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.frame = CGRectMake(0, CHATPOPVIEWTOP, kScreenWidth, kScreenHeight - CHATPOPVIEWTOP);
            } completion:^(BOOL finished) {
                
            }];
        }
    } else if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        if (CGRectGetMinX(self.frame) > kScreenHeight - 150.f) {
            [UIView animateWithDuration:0.25 delay:0.f usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.frame = CGRectMake(kScreenHeight, 0, MeetingMenuSliderWidth, kScreenWidth);
            } completion:^(BOOL finished) {
                // 页面移出
                if (self.delegate && [self.delegate respondsToSelector:@selector(meetingChatBaseViewNeedClose:)]) {
                    [self.delegate meetingChatBaseViewNeedClose:self];
                }
            }];
        } else {
            [UIView animateWithDuration:0.25 delay:0.f usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.frame = CGRectMake(kScreenHeight - MeetingMenuSliderWidth, 0, MeetingMenuSliderWidth, kScreenWidth);
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

#pragma mark - MeetChatRoomViewDelegate

- (void)meetingMenuBaseViewClose{
     if (self.delegate && [self.delegate respondsToSelector:@selector(meetingChatBaseViewNeedClose:)]) {
        [self.delegate meetingChatBaseViewNeedClose:self];
    }
}

- (void)meetChatRoomView:(MeetChatRoomView *)chatRoom DidUserInputText:(NSString *)text{
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return false;
}

#pragma mark - lazy load
- (MeetingMenuBaseTopView *)baseTopView {
    if (_baseTopView == nil) {
        CGRect frame = CGRectZero;
        if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
            frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 20.f);
        } else {
            frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 20.f);
        }
        _baseTopView = [[MeetingMenuBaseTopView alloc] initWithFrame:frame CurrentDeviceOrientation:self.orientation];
        _baseTopView.backgroundColor = UIColor.whiteColor;
    }
    return _baseTopView;
}

- (MeetChatRoomView *)chatListView {
    if (_chatListView == nil) {
        CGRect frame = CGRectZero;
        if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
            frame = CGRectMake(20, 0, CGRectGetWidth(self.frame) - 20, CGRectGetHeight(self.frame));
        } else {
            frame = CGRectMake(0, 20, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 20.f);
        }
        _chatListView = [[MeetChatRoomView alloc] initWithFrame:frame];
        _chatListView.delegatee = self;
    }
    return _chatListView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

@end
