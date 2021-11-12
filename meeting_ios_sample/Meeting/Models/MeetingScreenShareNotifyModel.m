//
//  MeetingScreenShareNotifyModel.m
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/10/20.
//

#import "MeetingScreenShareNotifyModel.h"

static NSString * const notification_indentify =        @"CLS_SCREENSHARE_BEGIN_NOTIFICATIONID";
static NSString * const notification_stop_indentify =   @"CLS_SCREENSHARE_STOP_NOTIFICATIONID";
static NSString * const notification_close_indentify =  @"CLS_SCREENSHARE_NEED_CLOSE_NOTIFICATIONID";


@implementation MeetingScreenShareNotifyModel

void StartHoleNotificationCallback(CFNotificationCenterRef center,
                                   void * observer,
                                   CFStringRef name,
                                   void const * object,
                                   CFDictionaryRef userInfo) {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHARE_BEGIN_NOTICE
                                                        object:nil
                                                      userInfo:nil];
}

void StopHoleNotificationCallback(CFNotificationCenterRef center,
                                   void * observer,
                                   CFStringRef name,
                                   void const * object,
                                   CFDictionaryRef userInfo) {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHARE_STOP_NOTICE
                                                        object:nil
                                                      userInfo:nil];
}

+ (void)registerBeginNotification:(id)object {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)notification_indentify;
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(object),
                                    StartHoleNotificationCallback,
                                    str,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

+ (void)registStopNotification:(id)object {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)notification_stop_indentify;
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(object),
                                    StopHoleNotificationCallback,
                                    str,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

+ (void)postCloseNotification {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)notification_close_indentify;
    CFNotificationCenterPostNotification(center, str, NULL, NULL, true);
}

@end
