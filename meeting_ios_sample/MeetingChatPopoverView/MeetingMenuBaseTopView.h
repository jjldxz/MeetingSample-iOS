//
//  MeetingMenuBaseTopView.h
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/3/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetingMenuBaseTopView : UIView

- (instancetype)initWithFrame:(CGRect)frame CurrentDeviceOrientation:(UIDeviceOrientation)ori;

- (void)changeDeviceOrientation:(UIDeviceOrientation)ori;

@end

NS_ASSUME_NONNULL_END
