//
//  ZHDrawingCircleLayer.h
//  ZHFigureDrawingLayer
//
//  Created by 周亚楠 on 2019/9/4.
//  Copyright © 2019 Zhou. All rights reserved.
//

#import "ZHFigureDrawingLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHDrawingCircleLayer : ZHFigureDrawingLayer

@property (nonatomic, assign, readonly) CGFloat r;
@property (nonatomic) CGPoint centerPoint;

- (void)movedRadius:(CGFloat)radius;

- (void)moveEndPoint:(CGPoint)end_p;

@end

NS_ASSUME_NONNULL_END
