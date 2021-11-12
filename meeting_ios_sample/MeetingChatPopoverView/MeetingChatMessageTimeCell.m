//
//  MeetingChatMessageTimeCell.m
//  meeting_iOS
//
//  Created by HYWD on 2021/7/10.
//

#import "MeetingChatMessageTimeCell.h"
#import <YYKit/YYKit.h>

@interface MeetingChatMessageTimeCell()
@property (nonatomic, strong)UILabel *chatMesasgeTime_label;
@end

@implementation MeetingChatMessageTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.chatMesasgeTime_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.chatMesasgeTime_label.frame = self.bounds;
}

- (void)loadUIWithData:(MeetingChatMessageDataModel *)data_model {
    self.chatMesasgeTime_label.text = data_model.nowTimeStr;
}

- (UILabel *)chatMesasgeTime_label {
    if (_chatMesasgeTime_label == nil) {
        _chatMesasgeTime_label = [UILabel new];
        _chatMesasgeTime_label.textAlignment = NSTextAlignmentCenter;
        _chatMesasgeTime_label.font = [UIFont systemFontOfSize:12.f];
        _chatMesasgeTime_label.textColor = [UIColor colorWithHexString:@"0x999999"];
        _chatMesasgeTime_label.numberOfLines = 1;
    }
    return _chatMesasgeTime_label;
}

@end
