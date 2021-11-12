//
//  MeetingChatMessageTimeCell.h
//  meeting_iOS
//
//  Created by HYWD on 2021/7/10.
//

#import <UIKit/UIKit.h>
#import "MeetingChatMessageDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MeetingChatMessageTimeCell : UITableViewCell
- (void)loadUIWithData:(MeetingChatMessageDataModel *)data_model;
@end

NS_ASSUME_NONNULL_END
