//
//  MeetingChatMessageDataModel.m
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/6.
//

#import "MeetingChatMessageDataModel.h"
#import <YYKit/YYKit.h>

@interface MeetingChatMessageDataModel ()

@property (assign, nonatomic, readwrite) CGSize text_size;

@end

@implementation MeetingChatMessageDataModel

- (void)setChat_message:(NSString *)chat_message {
    _chat_message = chat_message.copy;
    [self performSelectorOnMainThread:@selector(calTextSize:) withObject:chat_message waitUntilDone:YES modes:@[NSRunLoopCommonModes]];
}

- (void)calTextSize:(NSString *)text {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(calTextSize:) object:text];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeText addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.f], NSParagraphStyleAttributeName : paragraphStyle} range:NSMakeRange(0, text.length)];
    CGRect textRect = [attributeText boundingRectWithSize:CGSizeMake((kScreenWidth - 120.f), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    self.text_size = CGSizeMake(CGRectGetWidth(textRect) + fabs(textRect.origin.x), CGRectGetHeight(textRect) + fabs(textRect.origin.y));
}

@end
