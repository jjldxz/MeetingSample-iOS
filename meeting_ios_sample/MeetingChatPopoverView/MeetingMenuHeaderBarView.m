//
//  MeetingMenuHeaderBarView.m
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/3/25.
//

#import "MeetingMenuHeaderBarView.h"
#import <YYKit/YYKit.h>

@interface MeetingMenuHeaderBarView ()

@property (strong, nonatomic) UIButton *settingView;

@property (strong, nonatomic) UIButton *closeButton;

@property (strong, nonatomic) UIView *lineView;

@end

@implementation MeetingMenuHeaderBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.titleLabel];
        [self addSubview:self.closeButton];
        [self addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _settingView.bounds = CGRectMake(0, 0, 30.f, 30.f);
    _settingView.center = CGPointMake(30.f, CGRectGetHeight(self.frame) * 0.5);
    
    [_titleLabel sizeToFit];
    _titleLabel.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.4);
    
    _closeButton.bounds = CGRectMake(0, 0, 15.f, 15.f);
    _closeButton.center = CGPointMake(CGRectGetWidth(self.frame) - 30.f, CGRectGetHeight(self.frame) * 0.4);
    
    _lineView.bounds = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5f);
    _lineView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, (CGRectGetHeight(self.frame) - 1));
}

- (void)changeCurrentMeetingRoomMemberCount:(NSUInteger)count {
    _titleLabel.text = [NSString stringWithFormat:@"Attendees", count];
    [self setNeedsLayout];
}

#pragma mark - 设置按钮
- (void)settingsActions {
    if (_delegate && [_delegate respondsToSelector:@selector(meetingMenuHeaderNeedJumpToSetingPage)]) {
        [_delegate meetingMenuHeaderNeedJumpToSetingPage];
    }
}

#pragma mark - 关闭页面
- (void)closeMemberManageView {
    if (_delegate && [_delegate respondsToSelector:@selector(meetingMenuHeaderNeedClose)]) {
        [_delegate meetingMenuHeaderNeedClose];
    }
}

#pragma mark - lazy load
- (UIButton *)settingView {
    if (_settingView == nil) {
        _settingView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingView setImage:[UIImage imageNamed:@"le"] forState:UIControlStateNormal];
        [_settingView addTarget:self action:@selector(settingsActions) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18.f];
        _titleLabel.text = @"Attendees(1)";
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"ln"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeMemberManageView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = UIView.new;
        _lineView.backgroundColor = [UIColor colorWithHexString:@"0xECECEC"];
    }
    return _lineView;
}

@end
