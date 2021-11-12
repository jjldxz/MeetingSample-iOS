//
//  ZHFigureDrawingView.m
//  ZHFigureDrawingLayer
//
//  Created by 周亚楠 on 2019/9/5.
//  Copyright © 2019 Zhou. All rights reserved.
//

#import "ZHFigureDrawingView.h"
#import "ZHDrawingCircleLayer.h"
#import "DrawPageRevokeInfoModel.h"
#import <YYKit/YYKit.h>

@interface ZHFigureDrawingView ()

@property (nonatomic, assign) BOOL isFirstTouch;//区分点击与滑动手势
@property (nonatomic, strong) CALayer *drawingLayer;
@property (nonatomic, strong) NSMutableArray *layerArr;
@property (nonatomic, strong) NSMutableArray<DXZEducationRevokeInfoModel *> *previousLayerArr;
@property (nonatomic, strong) NSMutableArray<DXZEducationRevokeInfoModel *> *removeLayerArr;
@property (nonatomic, strong) NSMutableDictionary<NSString *, __kindof CALayer *> *drawInfo;
@property (nonatomic, assign) BOOL showTextLayer;
@property (nonatomic, copy) NSString *tmpText;

@end

@implementation ZHFigureDrawingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.fontSize = 15.f;
        self.drawEnable = YES;
        self.drawInfo = [NSMutableDictionary dictionary];
        self.previousLayerArr = [NSMutableArray array];
        self.layerArr = [NSMutableArray array];
        self.removeLayerArr = [NSMutableArray array];
        self.drawingType = ZHFigureDrawingTypeGraffiti;
        self.lineColor = [UIColor blackColor];
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)releaseSourceDatas {
    [self.layer removeAllSublayers];
    [_drawInfo removeAllObjects];
    [_layerArr removeAllObjects];
    [_previousLayerArr removeAllObjects];
    [_removeLayerArr removeAllObjects];
}

- (void)setDrawEnable:(BOOL)drawEnable {
    _drawEnable = drawEnable;
    self.userInteractionEnabled = drawEnable;
}

- (void)setDrawingType:(ZHFigureDrawingType)drawingType {
    if (_drawingType != drawingType) {
        if (_drawingType == ZHFigureDrawingTypeText) {
            _showTextLayer = NO;
            _tmpText = nil;
        }
        [NSObject willChangeValueForKey:@"drawingType"];
        _drawingType = drawingType;
        [NSObject didChangeValueForKey:@"drawingType"];
    }
}

#pragma mark - 绘画的描绘事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDXZLvbWiteboardActiveNotificationName object:nil userInfo:@{@"active" : @(YES)}];
    if (_drawEnable) {
        if (!self.showTextLayer) {
            self.isFirstTouch = YES;
        }
        if (self.showTextLayer == NO && self.drawingType != ZHFigureDrawingTypeNULL) {
            UITouch *touch = [touches anyObject];
            CGPoint currentPoint = [touch locationInView:self];
            CGPoint previousPoint = [touch previousLocationInView:self];
            BOOL isIn = [self.layer containsPoint:previousPoint];
            if (isIn) {
                if (self.isFirstTouch) {
                    ZHFigureDrawingLayer *zhfdrawingLayer = [ZHFigureDrawingLayer createLayerWithStartPoint:previousPoint type:self.drawingType];
                    zhfdrawingLayer.paintSize = self.frame.size;
                    zhfdrawingLayer.drawingType = self.drawingType;
                    zhfdrawingLayer.lineColor = self.lineColor;
                    zhfdrawingLayer.uuid = [NSString stringWithUUID];
                    if (zhfdrawingLayer) {
                        [self.layer addSublayer:zhfdrawingLayer];
                        self.drawingLayer = zhfdrawingLayer;
                        [self.drawInfo setObject:self.drawingLayer forKey:zhfdrawingLayer.uuid];
                    }
                } else {
                    [(ZHFigureDrawingLayer *)self.drawingLayer movePathWithEndPoint:currentPoint];
                }
                [self handleDrawDataInfo:self.drawingLayer CurerntPoint:previousPoint];
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_drawEnable) {
        if (self.showTextLayer == NO && self.drawingType != ZHFigureDrawingTypeNULL) {
            UITouch *touch = [touches anyObject];
            CGPoint currentPoint = [touch locationInView:self];
            CGPoint previousPoint = [touch previousLocationInView:self];
            BOOL isIn = [self.layer containsPoint:previousPoint];
            if (isIn) {
                if (self.isFirstTouch) {
                    ZHFigureDrawingLayer *zhfdrawingLayer = [ZHFigureDrawingLayer createLayerWithStartPoint:previousPoint type:self.drawingType];
                    zhfdrawingLayer.paintSize = self.frame.size;
                    zhfdrawingLayer.drawingType = self.drawingType;
                    zhfdrawingLayer.lineColor = self.lineColor;
                    zhfdrawingLayer.uuid = [NSString stringWithUUID];
                    if (zhfdrawingLayer) {
                        [self.layer addSublayer:zhfdrawingLayer];
                        self.drawingLayer = zhfdrawingLayer;
                        [self.drawInfo setObject:self.drawingLayer forKey:zhfdrawingLayer.uuid];
                    }
                } else {
                    [(ZHFigureDrawingLayer *)self.drawingLayer movePathWithEndPoint:currentPoint];
                }
                [self handleDrawDataInfo:self.drawingLayer CurerntPoint:previousPoint];
                self.isFirstTouch = NO;
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (_drawEnable && self.drawingType != ZHFigureDrawingTypeNULL) {
        if (self.showTextLayer) {
            UITouch *touch = [touches anyObject];
            CGPoint previousPoint = [touch previousLocationInView:self];
            ZHDTextLayer *textLayer = [ZHDTextLayer layer];
            textLayer.uuid = [NSString stringWithUUID];
            NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:self.tmpText attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Microsoft YaHei" size:self.fontSize], NSForegroundColorAttributeName : self.lineColor}];
            textLayer.string = attributeText.copy;
    //        textLayer.wrapped = YES; //为yes时自动换行
            textLayer.truncationMode = kCATruncationNone;
            textLayer.contentsScale = [UIScreen mainScreen].scale;
            CGRect textRect = [attributeText boundingRectWithSize:CGSizeMake(MAXFLOAT, self.fontSize) options:NSStringDrawingUsesFontLeading context:nil];
            textLayer.frame = CGRectMake(previousPoint.x, previousPoint.y, CGRectGetWidth(textRect), CGRectGetHeight(textRect));
            [self.layer addSublayer:textLayer];
            [self.layerArr addObject:textLayer];
            [self.drawInfo setObject:textLayer forKey:textLayer.uuid];
            self.showTextLayer = NO;
            [self handleEndDrawWithInfo:textLayer CurerntPoint:previousPoint];
        } else {
            if (self.drawingLayer) {
                UITouch *touch = [touches anyObject];
                CGPoint currentPoint = [touch locationInView:self];
                CGPoint previousPoint = [touch previousLocationInView:self];
                BOOL isIn = [self.layer containsPoint:previousPoint];
                [self.layerArr addObject:self.drawingLayer];
                [self.previousLayerArr removeAllObjects];
                [self.removeLayerArr removeAllObjects];
                if (isIn) {
                    [(ZHFigureDrawingLayer *)self.drawingLayer movePathWithEndPoint:currentPoint];
                    [self handleEndDrawWithInfo:self.drawingLayer CurerntPoint:previousPoint];
                } else {
                    ZHFigureDrawingLayer *zhfLayer = (ZHFigureDrawingLayer *)self.drawingLayer;
                    [self handleEndDrawWithInfo:self.drawingLayer CurerntPoint:zhfLayer.endPoint];
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDXZLvbWiteboardActiveNotificationName object:nil userInfo:@{@"active" : @(NO)}];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_drawEnable && self.drawingType != ZHFigureDrawingTypeNULL) {
        if (self.showTextLayer) {
            UITouch *touch = [touches anyObject];
            CGPoint previousPoint = [touch previousLocationInView:self];
            ZHDTextLayer *textLayer = [ZHDTextLayer layer];
            textLayer.uuid = [NSString stringWithUUID];
            NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:self.tmpText attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Microsoft YaHei" size:self.fontSize], NSForegroundColorAttributeName : self.lineColor}];
            textLayer.string = attributeText.copy;
    //        textLayer.wrapped = YES; //为yes时自动换行
            textLayer.truncationMode = kCATruncationNone;
            textLayer.contentsScale = [UIScreen mainScreen].scale;
            CGRect textRect = [attributeText boundingRectWithSize:CGSizeMake(MAXFLOAT, self.fontSize) options:NSStringDrawingUsesFontLeading context:nil];
            textLayer.frame = CGRectMake(previousPoint.x, previousPoint.y, CGRectGetWidth(textRect), CGRectGetHeight(textRect));
            [self.layer addSublayer:textLayer];
            [self.layerArr addObject:textLayer];
            [self.drawInfo setObject:textLayer forKey:textLayer.uuid];
            self.showTextLayer = NO;
            [self handleEndDrawWithInfo:textLayer CurerntPoint:previousPoint];
        } else {
            if (self.drawingLayer) {
                UITouch *touch = [touches anyObject];
                CGPoint previousPoint = [touch previousLocationInView:self];
                BOOL isIn = [self.layer containsPoint:previousPoint];
                if (isIn) {
                    [self.layerArr addObject:self.drawingLayer];
                    [self.previousLayerArr removeAllObjects];
                    [self.removeLayerArr removeAllObjects];
                    [self handleEndDrawWithInfo:self.drawingLayer CurerntPoint:previousPoint];
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDXZLvbWiteboardActiveNotificationName object:nil userInfo:@{@"active" : @(NO)}];
}

#pragma mark - 处理实时数据
- (void)handleDrawDataInfo:(__kindof CALayer *)drawLayer CurerntPoint:(CGPoint)touchPoint {
    if (self.drawCallback) {
        if ([drawLayer isKindOfClass:[ZHFigureDrawingLayer class]]) {
            ZHFigureDrawingLayer *drawingLayer = (ZHFigureDrawingLayer *)drawLayer;
            NSString *hexColorString = [NSString stringWithFormat:@"#%@", [drawingLayer.lineColor hexString]];
            NSString *startPoint = NSStringFromCGPoint(CGPointMake(drawingLayer.startPoint.x / self.width, drawingLayer.startPoint.y / self.height));
            NSString *endPoint = NSStringFromCGPoint(CGPointMake(touchPoint.x / self.width, touchPoint.y / self.height));
            NSUInteger lineWidth = (NSUInteger)(drawingLayer.lineWidth * [UIScreen mainScreen].scale);
            NSDictionary *drawInfoDict = @{
                @"uuid" : drawingLayer.uuid,
                @"lineColor" : hexColorString,
                @"start_point" : startPoint,
                @"lineWidth" : @(lineWidth),
                @"drawType" : @(drawingLayer.drawingType),
                @"time" : @([NSDate date].timeIntervalSince1970),
                @"end_point" : endPoint
            };
            NSMutableDictionary *drawParameter = [NSMutableDictionary dictionaryWithDictionary:drawInfoDict];
            if ([drawLayer isKindOfClass:[ZHDrawingCircleLayer class]]) {
                ZHDrawingCircleLayer *circleLayer = (ZHDrawingCircleLayer *)drawLayer;
                NSMutableString *centerPoint = [NSMutableString string];
                if (self.isFirstTouch == YES) {
                    [centerPoint appendString:endPoint.copy];
                } else {
                    [centerPoint appendString:NSStringFromCGPoint(CGPointMake(circleLayer.centerPoint.x / self.width, circleLayer.centerPoint.y / self.height))];
                }
                [drawParameter setObject:centerPoint.copy forKey:@"start_point"];
            }
            self.drawCallback(CGPointMake(touchPoint.x / self.width, touchPoint.y / self.height), (self.isFirstTouch == YES), drawParameter);
        }
    }
}

- (void)handleEndDrawWithInfo:(__kindof CALayer *)drawLayer CurerntPoint:(CGPoint)touchPoint {
    if (self.drawCallback) {
        if ([drawLayer isKindOfClass:[CATextLayer class]]) {
            NSString *hexColorString = [NSString stringWithFormat:@"#%@", [self.lineColor hexString]];
            @weakify(self)
            [self.drawInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, __kindof CALayer * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isEqual:drawLayer]) {
                    ZHDTextLayer *textLayer = (ZHDTextLayer *)drawLayer;
                    NSString *startPoint = NSStringFromCGPoint(CGPointMake(CGRectGetMinX(textLayer.frame) / weak_self.width, CGRectGetMaxY(textLayer.frame) / weak_self.height));
                    NSUInteger lineWidth = (NSUInteger)(round(self.fontSize * (96.f / 72.f) / 10.f));
                    NSDictionary *drawInfoDict = @{
                        @"uuid" : textLayer.uuid,
                        @"lineColor" : hexColorString,
                        @"start_point" : startPoint,
                        @"lineWidth" : @(lineWidth),
                        @"drawType" : @(ZHFigureDrawingTypeText),
                        @"time" : @([NSDate date].timeIntervalSince1970),
                        @"content" : [weak_self.tmpText copy],
                        @"end_point" : startPoint,
                        @"textW" : @(CGRectGetWidth(textLayer.frame) / self.width),
                        @"textH" : @(CGRectGetHeight(textLayer.frame) / self.height)
                    };
                    weak_self.drawCallback(CGPointMake(touchPoint.x / weak_self.width, touchPoint.y / weak_self.height), NO, drawInfoDict);
                }
            }];
            self.drawingType = ZHFigureDrawingTypeGraffiti;
        } else {
            ZHFigureDrawingLayer *drawingLayer = (ZHFigureDrawingLayer *)drawLayer;
            NSString *hexColorString = [NSString stringWithFormat:@"#%@", [drawingLayer.lineColor hexString]];
            NSString *startPoint = NSStringFromCGPoint(CGPointMake(drawingLayer.startPoint.x / self.width, drawingLayer.startPoint.y / self.height));
            NSString *endPoint = NSStringFromCGPoint(CGPointMake(touchPoint.x / self.width, touchPoint.y / self.height));
            NSUInteger lineWidth = (NSUInteger)(drawingLayer.lineWidth * [UIScreen mainScreen].scale);
            NSDictionary *drawInfoDict = @{
                @"uuid" : drawingLayer.uuid,
                @"lineColor" : hexColorString,
                @"start_point" : startPoint,
                @"lineWidth" : @(lineWidth),
                @"drawType" : @(drawingLayer.drawingType),
                @"time" : @([NSDate date].timeIntervalSince1970),
                @"end_point" : endPoint
            };
            NSMutableDictionary *drawParameter = [NSMutableDictionary dictionaryWithDictionary:drawInfoDict];
            if ([drawLayer isKindOfClass:[ZHDrawingCircleLayer class]]) {
                ZHDrawingCircleLayer *circleLayer = (ZHDrawingCircleLayer *)drawLayer;
                NSString *centerPoint = NSStringFromCGPoint(CGPointMake(circleLayer.centerPoint.x / self.width, circleLayer.centerPoint.y / self.height));
                [drawParameter setObject:centerPoint forKey:@"start_point"];
            }
            self.drawCallback(CGPointMake(touchPoint.x / self.width, touchPoint.y / self.height), NO, drawParameter);
        }
    }
}

#pragma mark - 铅笔描画
- (void)beginDrawLinePicWithModel:(DrawLineControlInfoModel *)lineInfoModel {
    if ([self.drawInfo.allKeys containsObject:lineInfoModel.Id]) {
        // 已存在的线
        ZHFigureDrawingLayer *draw_Layer = [self.drawInfo objectForKey:lineInfoModel.Id];
        if (![draw_Layer isKindOfClass:CATextLayer.class]) {
            @weakify(self)
            [lineInfoModel.points enumerateObjectsUsingBlock:^(DrawPointModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [draw_Layer movePathWithEndPoint:CGPointMake(weak_self.width * obj.x, weak_self.height * obj.y)];
            }];
        }
    } else {
        // 一条新线
        DrawPointModel *pointModel = lineInfoModel.points.firstObject;
        ZHFigureDrawingLayer *drawNewLayer = [ZHFigureDrawingLayer createLayerWithStartPoint:CGPointMake(self.width * pointModel.x, self.height * pointModel.y) type:ZHFigureDrawingTypeGraffiti];
        drawNewLayer.uuid = lineInfoModel.Id;
        drawNewLayer.paintSize = self.frame.size;
        drawNewLayer.drawingType = ZHFigureDrawingTypeGraffiti;
        drawNewLayer.lineColor = lineInfoModel.lineColor.length == 7 ? [UIColor colorWithHexString:lineInfoModel.lineColor] : UIColor.blackColor;
        drawNewLayer.layerLineWidth = lineInfoModel.lineWidth / [UIScreen mainScreen].scale;
        [self.layer addSublayer:drawNewLayer];
        [self.layerArr addObject:drawNewLayer];
        [self.drawInfo setObject:drawNewLayer forKey:lineInfoModel.Id];
        [self.previousLayerArr removeAllObjects];
        [self.removeLayerArr removeAllObjects];
        if (lineInfoModel.points.count > 1) {
            [self beginDrawLinePicWithModel:lineInfoModel];
        }
    }
}

#pragma mark - 图形描画
- (void)beginDrawShapWithModel:(DrawShapeControlInfoModel *)model {
    if ([model.type isEqualToString:@"drw_straight_line"]) { // 画直线
        if ([self.drawInfo.allKeys containsObject:model.Id]) {
            ZHFigureDrawingLayer *draw_Layer = (ZHFigureDrawingLayer *)[self.drawInfo objectForKey:model.Id];
            [draw_Layer movePathWithEndPoint:CGPointMake(self.width * model.endDot.x, self.height * model.endDot.y)];
        } else {
            ZHFigureDrawingLayer *drawNewLayer = [ZHFigureDrawingLayer createLayerWithStartPoint:CGPointMake(self.width * model.startDot.x, self.height * model.startDot.y) type:ZHFigureDrawingTypeLine];
            drawNewLayer.uuid = model.Id;
            drawNewLayer.paintSize = self.frame.size;
            drawNewLayer.drawingType = ZHFigureDrawingTypeLine;
            drawNewLayer.lineColor = model.lineColor.length == 7 ? [UIColor colorWithHexString:model.lineColor] : UIColor.blackColor;
            drawNewLayer.layerLineWidth = model.lineWidth / [UIScreen mainScreen].scale;
            [self.drawInfo setObject:drawNewLayer forKey:model.Id];
            [self.layerArr addObject:drawNewLayer];
            [self.layer addSublayer:drawNewLayer];
            [self.previousLayerArr removeAllObjects];
            [self.removeLayerArr removeAllObjects];
            [drawNewLayer movePathWithEndPoint:CGPointMake(self.width * model.endDot.x, self.height * model.endDot.y)];
        }
    } else if ([model.type isEqualToString:@"drw_rect"]) { // 画矩形
        if ([self.drawInfo.allKeys containsObject:model.Id]) {
            ZHFigureDrawingLayer *draw_Layer = (ZHFigureDrawingLayer *)[self.drawInfo objectForKey:model.Id];
            [draw_Layer movePathWithEndPoint:CGPointMake(self.width * model.endDot.x, self.height * model.endDot.y)];
        } else {
            ZHFigureDrawingLayer *drawNewLayer = [ZHFigureDrawingLayer createLayerWithStartPoint:CGPointMake(self.width * model.startDot.x, self.height * model.startDot.y) type:ZHFigureDrawingTypeRect];
            drawNewLayer.paintSize = self.frame.size;
            drawNewLayer.drawingType = ZHFigureDrawingTypeRect;
            drawNewLayer.lineColor = [UIColor colorWithHexString:model.lineColor];
            drawNewLayer.layerLineWidth = model.lineWidth / [UIScreen mainScreen].scale;
            drawNewLayer.uuid = [model.Id copy];
            [self.layerArr addObject:drawNewLayer];
            [self.previousLayerArr removeAllObjects];
            [self.removeLayerArr removeAllObjects];
            [self.drawInfo setObject:drawNewLayer forKey:model.Id];
            [self.layer addSublayer:drawNewLayer];
            [drawNewLayer movePathWithEndPoint:CGPointMake(self.width * model.endDot.x, self.height * model.endDot.y)];
        }
    } else if ([model.type isEqualToString:@"drw_round"]) { // 画圆
        if ([self.drawInfo.allKeys containsObject:model.Id]) {
            ZHDrawingCircleLayer *draw_Layer = (ZHDrawingCircleLayer *)[self.drawInfo objectForKey:model.Id];
            CGPoint end_point = CGPointMake(model.endDot.x * self.width, model.endDot.y * self.height);
            draw_Layer.centerPoint = CGPointMake(self.width * model.startDot.x, self.height * model.startDot.y);
            [draw_Layer moveEndPoint:end_point];
//            [draw_Layer movedRadius:r];
        } else {
            ZHDrawingCircleLayer *drawNewLayer = [ZHDrawingCircleLayer createLayerWithStartPoint:CGPointMake(self.width * (model.startDot.x * 2 - model.endDot.x), self.height * (model.startDot.y * 2 - model.endDot.y)) type:ZHFigureDrawingTypeCircle];
            drawNewLayer.paintSize = self.frame.size;
            drawNewLayer.drawingType = ZHFigureDrawingTypeCircle;
            drawNewLayer.lineColor = [UIColor colorWithHexString:model.lineColor];
            drawNewLayer.layerLineWidth = model.lineWidth / [UIScreen mainScreen].scale;
            drawNewLayer.uuid = [model.Id copy];
            [self.drawInfo setObject:drawNewLayer forKey:model.Id];
            [self.layerArr addObject:drawNewLayer];
            [self.layer addSublayer:drawNewLayer];
            [self.previousLayerArr removeAllObjects];
            [self.removeLayerArr removeAllObjects];
            drawNewLayer.centerPoint = CGPointMake(self.width * model.startDot.x, self.height * model.startDot.y);
            CGPoint end_point = CGPointMake(model.endDot.x * self.width, model.endDot.y * self.height);
            [drawNewLayer moveEndPoint:end_point];
        }
    } else if ([model.type isEqualToString:@"drw_clearall"]) { // 清屏
        @weakify(self)
        [self.drawInfo.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CALayer *drawed_layer = [weak_self.drawInfo objectForKey:obj];
            [drawed_layer removeFromSuperlayer];
        }];
        [self removeAllLayerDrawing];
        [self.drawInfo removeAllObjects];
    } else if ([model.type isEqualToString:@"drw_delete"]) {
        if ([self.drawInfo.allKeys containsObject:model.targetId]) {
            CALayer *drawed_layer = [self.drawInfo objectForKey:model.targetId];
            [drawed_layer removeFromSuperlayer];
            [self.drawInfo removeObjectForKey:model.targetId];
            [self.layerArr removeObject:drawed_layer];
            DXZEducationRevokeInfoModel *model = [[DXZEducationRevokeInfoModel alloc] initWithLocalRevokeViews:@[drawed_layer]];
            [self.previousLayerArr addObject:model];
            [self.removeLayerArr addObject:model];
        } else {
            return;
        }
    } else if ([model.type isEqualToString:@"drw_text"]) {
        ZHDTextLayer *textLayer = [ZHDTextLayer layer];
        textLayer.uuid = model.Id;
        UIFont *font = [UIFont fontWithName:@"Microsoft YaHei" size:[self suitTestFontToSize:CGSizeMake(model.textW * self.width , model.textH * self.height) ContentText:model.content]];
        NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:[model.content copy] attributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor colorWithHexString:model.lineColor]}];
        textLayer.string = attributeText;      //文字颜色，普通字符串时可以使用该属性
//        textLayer.wrapped = YES;                               //为yes时自动换行
        textLayer.truncationMode = kCATruncationNone;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        CGRect textRect = [model.content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options: NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil];

        textLayer.bounds = CGRectMake(0.f, 0.f, CGRectGetWidth(textRect) - CGRectGetMinX(textRect), CGRectGetHeight(textRect) - CGRectGetMinY(textRect));
        textLayer.position = CGPointMake(model.startDot.x * self.width + CGRectGetWidth(textRect) * 0.5, model.startDot.y * self.height - (CGRectGetHeight(textRect) + 4.f) * 0.5 + 2);
        [self.layer addSublayer:textLayer];
        [self.layerArr addObject:textLayer];
        [self.drawInfo setObject:textLayer forKey:model.Id];
    } else if ([model.type isEqualToString:@"drw_revoke"]) {
        if ([self.drawInfo.allKeys containsObject:model.targetId]) {
            CALayer *drawed_layer = [self.drawInfo objectForKey:model.targetId];
            DXZEducationRevokeInfoModel *revokerModel = [DXZEducationRevokeInfoModel new];
            revokerModel.Id = model.Id.copy;
            revokerModel.drawViews = @[drawed_layer];
            [self.previousLayerArr addObject:revokerModel];
            [self.removeLayerArr addObject:revokerModel];
            [drawed_layer removeFromSuperlayer];
            [self.drawInfo removeObjectForKey:model.targetId];
            [self.layerArr removeObject:drawed_layer];
        } else {
            return;
        }
    } else {
        return;
    }
}

- (NSInteger)suitTestFontToSize:(CGSize)size ContentText:(NSString *)content {
    BOOL isSuit = NO;
    NSInteger beginSize = 6;
    while (!isSuit) {
        CGRect cal_rect = [content boundingRectWithSize:size options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Microsoft YaHei" size:beginSize]} context:nil];
        NSString *cal_text_width = [NSString stringWithFormat:@"%.2f", cal_rect.size.width - cal_rect.origin.x];
        NSString *size_width = [NSString stringWithFormat:@"%.2f", size.width];
        if (cal_text_width.floatValue > size_width.floatValue) {
            beginSize --;
            isSuit = YES;
        } else if (cal_text_width.floatValue == size_width.floatValue) {
            isSuit = YES;
        } else {
            beginSize ++;
        }
    }
    return beginSize;
}

#pragma mark - 前进一步
- (void)nextStep {
    if (!self.previousLayerArr.count) {
        return;
    }
    DXZEducationRevokeInfoModel *model = [self.previousLayerArr lastObject];
    for (CALayer *draw_layer in model.drawViews) {
        [self.layerArr addObject:draw_layer];
        [self.layer addSublayer:draw_layer];
    }
    [self.previousLayerArr removeObject:model];
}

//撤销一步
- (void)previousStep {
    if (!self.layerArr.count) {
        return;
    }
    [self revokeLastOperation];
}

- (void)removePageLayerWithId:(NSString *)uuid {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF.uuid == %@", uuid];
    NSArray *array = [self.layerArr filteredArrayUsingPredicate:pre];
    if (array.count > 0) {
        for (CALayer *layers in array) {
            [layers removeFromSuperlayer];
            DXZEducationRevokeInfoModel *info = [DXZEducationRevokeInfoModel new];
            info.Id = uuid;
            info.drawViews = @[layers];
            [self.previousLayerArr addObject:info];
            [self.removeLayerArr addObject:info];
        }
        [self.layerArr removeObjectsInArray:array];
    }
}

- (void)revokeLastOperation {
    CALayer *drawingLayer = [self.layerArr lastObject];
    DXZEducationRevokeInfoModel *info = [[DXZEducationRevokeInfoModel alloc] initWithLocalRevokeViews:@[drawingLayer]];
    [self.layerArr removeObject:drawingLayer];
    [self.previousLayerArr addObject:info];
    [self.removeLayerArr addObject:info];
    [drawingLayer removeFromSuperlayer];
    if ([drawingLayer isKindOfClass:ZHDTextLayer.class]) {
        ZHDTextLayer *textLayer = (ZHDTextLayer *)drawingLayer;
        if (_delegate && [_delegate respondsToSelector:@selector(drawingViewDeleteWithId:TargetId:)]) {
            [_delegate drawingViewDeleteWithId:info.Id TargetId:textLayer.uuid];
        }
    } else {
        ZHFigureDrawingLayer *drawLayer = (ZHFigureDrawingLayer *)drawingLayer;
        if (_delegate && [_delegate respondsToSelector:@selector(drawingViewDeleteWithId:TargetId:)]) {
            [_delegate drawingViewDeleteWithId:info.Id TargetId:drawLayer.uuid];
        }
    }
}

- (void)revokeTargerOperation:(DrawPageRevokeInfoModel *)info {
    NSPredicate *previous_pre = [NSPredicate predicateWithFormat:@"SELF.Id == %@", info.Id];
    NSArray *searchArray = [self.removeLayerArr filteredArrayUsingPredicate:previous_pre];
    if (searchArray.count > 0) {
        for (DXZEducationRevokeInfoModel *layerInfo in searchArray) {
            for (CALayer *layer in layerInfo.drawViews) {
                [self.layer addSublayer:layer];
                [self.layerArr addObject:layer];
            }
        }
        [self.previousLayerArr removeObjectsInArray:searchArray];
        [self.removeLayerArr removeObjectsInArray:searchArray];
    } else {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF.uuid == %@", info.targetId];
        NSArray *array = [self.layerArr filteredArrayUsingPredicate:pre];
        if (array.count > 0) {
            for (CALayer *layers in array) {
                [layers removeFromSuperlayer];
                DXZEducationRevokeInfoModel *info = [DXZEducationRevokeInfoModel new];
                info.Id = info.Id;
                info.drawViews = @[layers];
                [self.previousLayerArr addObject:info];
                [self.removeLayerArr addObject:info];
            }
            [self.layerArr removeObjectsInArray:array];
        }
    }
}

//清除所有
- (void)removeAllLayerDrawing {
    if (!self.layerArr.count) {
        return;
    }
    for (CALayer *drawingLayer in self.layerArr) {
        [drawingLayer removeFromSuperlayer];
    }
    DXZEducationRevokeInfoModel *info = [[DXZEducationRevokeInfoModel alloc] initWithLocalRevokeViews:self.layerArr.copy];
    [self.removeLayerArr addObject:info];
    [self.previousLayerArr removeAllObjects];
    [self.layerArr removeAllObjects];
    if (self.drawEnable) {
        if (_delegate && [_delegate respondsToSelector:@selector(drawingViewClearAll:)]) {
            [_delegate drawingViewClearAll:info.Id];
        }
    }
}

//还原所有
- (void)rotateAllLayerDrawing {
    for (NSArray<__kindof CALayer *> *layers in self.removeLayerArr) {
        @weakify(self)
        [layers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weak_self.layer addSublayer:obj];
        }];
        [self.layerArr addObjectsFromArray:layers];
    }
    [self.removeLayerArr removeAllObjects];
}

// 设置文字内容,并准备绘制文字
- (void)drawTextInTheWBPage:(NSString *)text {
    if (text && text.length > 0) {
        self.tmpText = text.copy;
        self.showTextLayer = YES;
    } else {
        self.tmpText = nil;
        self.showTextLayer = NO;
    }
}

#pragma mark - dealloc
- (void)dealloc {
    [_drawInfo removeAllObjects];
    [_layerArr removeAllObjects];
    [_previousLayerArr removeAllObjects];
    [_removeLayerArr removeAllObjects];
    [self.layer removeAllSublayers];
    _drawInfo = nil;
    _layerArr = nil;
    _previousLayerArr = nil;
    _removeLayerArr = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
