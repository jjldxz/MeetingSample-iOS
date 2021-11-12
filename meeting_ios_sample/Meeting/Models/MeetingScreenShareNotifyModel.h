//
//  MeetingScreenShareNotifyModel.h
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/10/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define SHARE_BEGIN_NOTICE     @"MeetingScreenShareNotifyBegin"
#define SHARE_STOP_NOTICE      @"MeetingScreenShareNotifyStop"

@interface MeetingScreenShareNotifyModel : NSObject

+ (void)registerBeginNotification:(id)object;

+ (void)registStopNotification:(id)object;

+ (void)postCloseNotification;

@end

NS_ASSUME_NONNULL_END
