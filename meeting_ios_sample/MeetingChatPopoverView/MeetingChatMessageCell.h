//
//  MeetingChatMessageCell.h
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "MeetingChatMessageDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MeetingChatMessageCell : UITableViewCell

@property (assign, nonatomic) BOOL is_self;

- (void)loadUIWithData:(MeetingChatMessageDataModel *)data_model;

@end

NS_ASSUME_NONNULL_END
