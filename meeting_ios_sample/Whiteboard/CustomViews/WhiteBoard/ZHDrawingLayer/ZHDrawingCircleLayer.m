//
//  ZHDrawingCircleLayer.m
//  ZHFigureDrawingLayer
//
//  Created by 周亚楠 on 2019/9/4.
//  Copyright © 2019 Zhou. All rights reserved.
//

#import "ZHDrawingCircleLayer.h"

@interface ZHDrawingCircleLayer ()

@property (nonatomic, assign, readwrite) CGFloat r;

@end

@implementation ZHDrawingCircleLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.centerPoint = CGPointZero;
    }
    return self;
}

//圆
- (void)movePathWithEndPoint:(CGPoint)endPoint{
    
    self.endPoint = endPoint;
    
    self.centerPoint = CGPointMake(fabs(endPoint.x + self.startPoint.x) * 0.5, fabs(endPoint.y + self.startPoint.y) * 0.5);
    
    
    CGFloat radius = [self distanceBetweenStartPoint:self.startPoint endPoint:endPoint] * 0.5;
    
    self.r = radius;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:NO];
    self.path = path.CGPath;
}

- (void)movedRadius:(CGFloat)radius {
    self.r = radius;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:NO];
    self.path = path.CGPath;
}

- (void)moveEndPoint:(CGPoint)end_p {
    CGFloat radius = [self distanceBetweenStartPoint:self.centerPoint endPoint:end_p];
    self.r = radius;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:NO];
    self.path = path.CGPath;
}

@end
