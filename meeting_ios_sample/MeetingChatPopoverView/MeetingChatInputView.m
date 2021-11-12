//
//  MeetingChatInputView.m
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/1.
//

#import "MeetingChatInputView.h"
#import <YYKit/YYKit.h>

@interface MeetingChatInputView ()<UITextFieldDelegate>


@property (strong, nonatomic) UIButton *send_btn;
@property (strong, nonatomic) UIButton *sendUserButton;
@property (strong, nonatomic) UIImageView *sendImageView;
@property (strong, nonatomic) UILabel *sendLabel;
@property (strong, nonatomic) UIView *lineView;

@end

@implementation MeetingChatInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
//        self.sendUserInfo = RoomUserInfoModel.new;
        [self addSubview:self.lineView];
        [self addSubview:self.sendLabel];
        [self addSubview:self.sendUserButton];
        [self addSubview:self.sendImageView];
        [self addSubview:self.inputText];
        [self addSubview:self.send_btn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _lineView.frame = CGRectMake(0, 0,CGRectGetWidth(self.frame), 0.5);
    _sendLabel.frame = CGRectMake(20, 15,50, 20);
    
    [self.sendUserButton sizeToFit];
    _sendUserButton.frame = CGRectMake(55 , 5, self.sendUserButton.width, 40);

    _sendImageView.frame = CGRectMake(CGRectGetMaxX(_sendUserButton.frame) + 10 ,22, 8, 4.5);
    
    _inputText.frame = CGRectMake(15 , 50, CGRectGetWidth(self.frame) - 100, 35);
//    _inputText.layer.borderWidth = 1;
//    _inputText.layer.borderColor = graylineColor.CGColor;
    _inputText.layer.cornerRadius = 5.f;
    _inputText.layer.masksToBounds = YES;
    
    _send_btn.frame = CGRectMake(CGRectGetWidth(self.frame) - 75 , 50, 60, 35);

}

#pragma mark - 发送消息按钮
- (void)sendMessageAction {
    NSString *inputText = _inputText.text.copy;
    if (_delegate && [_delegate respondsToSelector:@selector(meetingChatInputView:DidFinishedEdit:UserInfo:)]) {
        [_delegate meetingChatInputView:self DidFinishedEdit:inputText UserInfo:self.sendUserInfo];
    }
    _inputText.text = nil;
    [_inputText resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *inputText = textField.text.copy;
    if (_delegate && [_delegate respondsToSelector:@selector(meetingChatInputView:DidFinishedEdit:UserInfo:)]) {
       [_delegate meetingChatInputView:self DidFinishedEdit:inputText UserInfo:self.sendUserInfo];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(meetingChatInputViewNeedClose:)]) {
        [_delegate meetingChatInputViewNeedClose:self];
    }
}

- (void)selectSendUserView{
    [self endEditing:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(meetingChatInputViewChoseUserList:)]) {
        [_delegate meetingChatInputViewChoseUserList:self];
    }
}

- (UITextField *)inputText {
    if (_inputText == nil) {
        _inputText = [[UITextField alloc] initWithFrame:CGRectMake(72.f, 16.f, CGRectGetWidth(self.frame) - 280.f, CGRectGetHeight(self.frame) - 32.f)];
        _inputText.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        _inputText.delegate = self;
        _inputText.font = [UIFont systemFontOfSize:14.f];
        _inputText.textColor = [UIColor colorWithHexString:@"0x333333"];
        _inputText.placeholder = @"Please enter the chat content";
        _inputText.returnKeyType = UIReturnKeySend;
        _inputText.leftView = [[UIView alloc]initWithFrame:CGRectMake(0,0,10,1)];
        _inputText.leftViewMode = UITextFieldViewModeAlways;
    }
    return _inputText;
}

- (UIButton *)send_btn {
    if (_send_btn == nil) {
        _send_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:@"Send"];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.alignment = NSTextAlignmentCenter;
        [attribute addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.f], NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName : UIColor.whiteColor} range:NSMakeRange(0, attribute.length)];
        [_send_btn setAttributedTitle:attribute.copy forState:UIControlStateNormal];
        [_send_btn addTarget:self action:@selector(sendMessageAction) forControlEvents:UIControlEventTouchUpInside];
        _send_btn.layer.cornerRadius = 5.f;
        _send_btn.layer.masksToBounds = YES;
        _send_btn.backgroundColor = [UIColor colorWithHexString:@"0x333333"];
    }
    return _send_btn;
}

- (UILabel *)sendLabel {
    if (_sendLabel == nil) {
        _sendLabel = UILabel.new;
        _sendLabel.font = [UIFont boldSystemFontOfSize:14];
        _sendLabel.text = @"To:";
        _sendLabel.textColor = UIColor.blackColor;
    }
    return _sendLabel;
}

- (UIButton *)sendUserButton {
    if (_sendUserButton == nil) {
        _sendUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendUserButton setTitleColor:[UIColor colorWithHexString:@"0x127BF8"] forState:UIControlStateNormal];
        _sendUserButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_sendUserButton setTitle:@"Everyone" forState:UIControlStateNormal];
        [_sendUserButton addTarget:self action:@selector(selectSendUserView) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _sendUserButton;
}

- (UIImageView *)sendImageView {
    if (_sendImageView == nil) {
        _sendImageView = UIImageView.new;
        _sendImageView.image = [UIImage imageNamed:@"chat_up"];
    }
    return _sendImageView;
}

- (UIView *)lineView{
    if (_lineView == nil) {
        _lineView = UIView.new;
        _lineView.backgroundColor = [UIColor colorWithHexString:@"0xEEEEEE"];
    }
    return _lineView;
}

@end
