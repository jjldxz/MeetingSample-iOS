//
//  MeetingMenuBaseTopView.m
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/3/30.
//

#import "MeetingMenuBaseTopView.h"

@interface MeetingMenuBaseTopView ()

@property (assign, nonatomic) UIInterfaceOrientation currentOrientation;
@property (strong, nonatomic) UIView *noticeLine;

@end

@implementation MeetingMenuBaseTopView

- (instancetype)initWithFrame:(CGRect)frame CurrentDeviceOrientation:(UIDeviceOrientation)ori {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleStatusBarOrientationChange:)
                                             name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        self.userInteractionEnabled = YES;
        [self addSubview:self.noticeLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.currentOrientation == UIInterfaceOrientationLandscapeLeft || self.currentOrientation == UIInterfaceOrientationLandscapeRight)  {
        _noticeLine.bounds = CGRectMake(0, 0, 5.f, 40.f);
        _noticeLine.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
    } else {
        _noticeLine.bounds = CGRectMake(0, 0, 40.f, 5.f);
        _noticeLine.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
    }
    _noticeLine.layer.cornerRadius = 2.5;
    _noticeLine.layer.masksToBounds = YES;
    
    [self setNeedsDisplay];
}

//界面方向改变的处理
- (void)handleStatusBarOrientationChange: (NSNotification *)notification{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.currentOrientation = interfaceOrientation;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    if (self.currentOrientation == UIDeviceOrientationLandscapeLeft || self.currentOrientation == UIDeviceOrientationLandscapeRight) {
        UIBezierPath *bez_path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(20.f, 20.f)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        shapeLayer.path = bez_path.CGPath;
        self.layer.mask = shapeLayer;
    } else {
        UIBezierPath *bez_path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20.f, 20.f)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        shapeLayer.path = bez_path.CGPath;
        self.layer.mask = shapeLayer;
    }
}

- (void)changeDeviceOrientation:(UIDeviceOrientation)ori {
    if (ori == UIDeviceOrientationPortrait || ori == UIDeviceOrientationLandscapeLeft || ori == UIDeviceOrientationLandscapeRight) {
        [self setNeedsDisplay];
    }
}
#pragma mark - lazy load
- (UIView *)noticeLine {
    if (_noticeLine == nil) {
        _noticeLine = [UIView new];
        _noticeLine.backgroundColor = UIColor.lightGrayColor;
    }
    return _noticeLine;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

@end
