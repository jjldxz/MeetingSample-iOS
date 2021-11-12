//
//  MeetingChatMessageCell.m
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/2.
//

#import "MeetingChatMessageCell.h"
#import <YYKit/YYKit.h>
#import "meeting_ios_sample-Swift.h"

@interface MeetingChatMessageCell ()

@property (strong, nonatomic) UIView *chatMessage_back;
@property (strong, nonatomic) UILabel *userName_label;
@property (strong, nonatomic) UILabel *chatMesasge_label;

@property (strong, nonatomic) MeetingChatMessageDataModel *data_model;

@end

@implementation MeetingChatMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.userName_label];
        [self.contentView addSubview:self.chatMessage_back];
        [self.chatMessage_back addSubview:self.chatMesasge_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_data_model) {
        if (_is_self) {
            [_userName_label sizeToFit];
            _chatMessage_back.backgroundColor = [UIColor colorWithHexString:@"0x127BF8"];;
            _chatMesasge_label.textColor = UIColor.whiteColor;
            _userName_label.center = CGPointMake(CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(_userName_label.bounds) * 0.5 - 16.f, 8.f + CGRectGetHeight(_userName_label.bounds) * 0.5);
            CGSize back_size = CGSizeMake(_data_model.text_size.width + 20.f,  _data_model.text_size.height + 14.f);
            _chatMessage_back.bounds = CGRectMake(0, 0, _data_model.text_size.width + 20.f, _data_model.text_size.height + 14.f);
            _chatMessage_back.center = CGPointMake(CGRectGetWidth(self.contentView.frame) - back_size.width * 0.5 - 16.f, CGRectGetMaxY(_userName_label.frame) + 4.f + back_size.height * 0.5);
            _chatMessage_back.layer.cornerRadius = 5.f;
            
            _chatMesasge_label.frame = CGRectMake(10, 7, _data_model.text_size.width, _data_model.text_size.height);
        } else {
            [_userName_label sizeToFit];
            _chatMessage_back.backgroundColor = [UIColor colorWithHexString:@"0xF8F8F8"];
            _chatMesasge_label.textColor = [UIColor colorWithHexString:@"0x333333"];
            _userName_label.center = CGPointMake(CGRectGetWidth(_userName_label.bounds) * 0.5 + 16.f, 8.f + CGRectGetHeight(_userName_label.bounds) * 0.5);
            CGSize back_size = CGSizeMake(_data_model.text_size.width + 20.f,  _data_model.text_size.height + 14.f);
            _chatMessage_back.bounds = CGRectMake(0, 0, _data_model.text_size.width + 20.f, _data_model.text_size.height + 14.f);
            _chatMessage_back.center = CGPointMake(back_size.width * 0.5 + 16.f, CGRectGetMaxY(_userName_label.frame) + 4.f + back_size.height * 0.5);
            _chatMessage_back.layer.cornerRadius = 5.f;
            
            _chatMesasge_label.frame = CGRectMake(10, 7, _data_model.text_size.width, _data_model.text_size.height);
        }
    }
}

- (void)loadUIWithData:(MeetingChatMessageDataModel *)data_model {
    _data_model = data_model;
    NSInteger textLength = 8;
    if (_is_self) {//我
        if (data_model.toUid.intValue == 0) {
            NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"From Me to Everyone"]];
            attributedText.color = [UIColor colorWithHexString:@"0xCCCCCC"];
            [attributedText setAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0xFFA210"]} range:NSMakeRange(attributedText.length - textLength, textLength)];
            _userName_label.attributedText = attributedText;
        }else{
            NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"From Me to %@ (Direct Message)",data_model.toUser_name]];
            attributedText.color = [UIColor colorWithHexString:@"0xCCCCCC"];
            [attributedText setAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0xFFA210"]} range:NSMakeRange(attributedText.length - data_model.toUser_name.length, data_model.toUser_name.length)];
            _userName_label.attributedText = attributedText;
        }
    }else{
        if (data_model.toUserId.length == 0) {
            NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"From %@ to Everyone",data_model.user_name,@"Everyone"]];
            attributedText.color = [UIColor colorWithHexString:@"0xCCCCCC"];
            [attributedText setAttributes:@{NSForegroundColorAttributeName :[UIColor colorWithHexString:@"0xFFA210"]} range:NSMakeRange(attributedText.length - textLength, textLength)];
            _userName_label.attributedText = attributedText;
        } else if(_is_self) {
            NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"From %@ to Me (Direct Message)",data_model.user_name]];
            attributedText.color = [UIColor colorWithHexString:@"0xCCCCCC"];
            NSInteger tomeTextLength = 20;
            [attributedText setAttributes:@{NSForegroundColorAttributeName :[UIColor colorWithHexString:@"0xFFA210"]} range:NSMakeRange(attributedText.length - tomeTextLength, tomeTextLength)];
            _userName_label.attributedText = attributedText;
        }
    }
    _chatMesasge_label.text = data_model.chat_message;
    [self setNeedsLayout];
}

#pragma mark - lazy load
- (UIView *)chatMessage_back {
    if (_chatMessage_back == nil) {
        _chatMessage_back = [UIView new];
    }
    return _chatMessage_back;
}

- (UILabel *)userName_label {
    if (_userName_label == nil) {
        _userName_label = [UILabel new];
        _userName_label.font = [UIFont systemFontOfSize:10];
        _userName_label.textColor = [UIColor colorWithHexString:@"0x999999"];
    }
    return _userName_label;
}

- (UILabel *)chatMesasge_label {
    if (_chatMesasge_label == nil) {
        _chatMesasge_label = [UILabel new];
        _chatMesasge_label.font = [UIFont systemFontOfSize:14];
        _chatMesasge_label.numberOfLines = 0;
    }
    return _chatMesasge_label;
}

@end
