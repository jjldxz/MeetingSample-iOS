//
//  ZHFigureDrawingView.h
//  ZHFigureDrawingLayer
//
//  Created by 周亚楠 on 2019/9/5.
//  Copyright © 2019 Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHFigureDrawingLayer.h"
#import "ZHDTextLayer.h"
#import "DrawLineControlInfoModel.h"
#import "DrawShapeControlInfoModel.h"
#import "DXZEducationRevokeInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

#define kDXZLvbWiteboardActiveNotificationName      @"kDXZLvbWiteboardActiveNotification"

@class DrawPageRevokeInfoModel;
typedef void(^FDViewDrawActionBlock)(CGPoint drawAtPoint, BOOL isFinished, NSDictionary *drawInfo);

@protocol ZHFigureDrawingViewActionDelegate <NSObject>

- (void)drawingViewClearAll:(NSString *)Id;

- (void)drawingViewPreviousStepWithModel:(DXZEducationRevokeInfoModel *)model;

- (void)drawingViewDeleteWithId:(NSString *)uuid TargetId:(NSString *)targetId;

@end

@interface ZHFigureDrawingView : UIImageView

@property (nonatomic, assign) ZHFigureDrawingType drawingType;
@property (nonatomic, strong) UIColor *lineColor;//画笔颜色
@property (nonatomic, copy) FDViewDrawActionBlock drawCallback;
@property (nonatomic, assign) BOOL drawEnable;
@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, weak) id<ZHFigureDrawingViewActionDelegate> delegate;


- (void)beginDrawLinePicWithModel:(DrawLineControlInfoModel *)lineInfoModel;

- (void)beginDrawShapWithModel:(DrawShapeControlInfoModel *)model;

- (void)nextStep;

- (void)previousStep;

- (void)removeAllLayerDrawing;

- (void)rotateAllLayerDrawing;

- (void)revokeLastOperation;

- (void)revokeTargerOperation:(DrawPageRevokeInfoModel *)info;

- (void)removePageLayerWithId:(NSString *)uuid;

- (void)drawTextInTheWBPage:(NSString *_Nullable)text;

- (void)releaseSourceDatas;

@end

NS_ASSUME_NONNULL_END
