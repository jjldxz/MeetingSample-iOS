//
//  WhiteboardPageView.h
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/31.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawLineControlInfoModel.h"
#import "DrawShapeControlInfoModel.h"
#import "DrawPageHistoryDataInfo.h"
#import "DrawPageRevokeInfoModel.h"
#import "WhiteboardToolsModel.h"

NS_ASSUME_NONNULL_BEGIN

#define NORMALWBTEXTFONTSIZE    (15.f)

@class DrawPageHistoryRevokeInfo, DrawPageHistoryRevokeInfo;
@protocol WhiteboardPageViewDrawDelegate <NSObject>

- (void)sendDrawActionJsonStringDatas:(NSString *)sendMessage;
@optional
- (void)whiteboardPageDidShowHistoryActiveIndex:(NSUInteger)index AtGroupId:(NSNumber *)groupId;

@end

@interface WhiteboardPageView : UIView

@property (nonatomic, getter=getWBTotalPages) NSUInteger totalPageCount;
@property (nonatomic, assign, readonly) NSUInteger pageNo;
@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, weak) id<WhiteboardPageViewDrawDelegate> drawDelegate;
@property (nonatomic, copy) NSNumber *drawStutes;
@property (nonatomic, assign) CGFloat fontSize;

/**
 铅笔绘制
 model : 铅笔绘画数据model
 */
- (void)pencilDrawInViewWithInfo:(DrawLineControlInfoModel *)model;
/**
 绘制形状 (直线 矩形 圆形 文字)
 model : 图形绘画数据model
 */
- (void)shapeDrawInViewWithOperation:(DrawShapeControlInfoModel *)model;
/**
 删除某一笔绘画
 index : 笔画的索引位置
 */
- (void)removeDrawPageWithIndex:(NSUInteger)index;
/**
 创建课件UI信息
 data : 课件列表数据model
 */

- (void)releaseResource;

- (void)revokeOperationWithModel:(DrawPageRevokeInfoModel *)model;

#pragma mark - 功能类接口
- (void)nextStepOnCurrentPage;

- (void)previousStepOnCurrentPage;

- (void)removeAllLayerDrawingOnCurrentPage;

- (void)rotateAllLayerDrawingOnCurrentPage;

- (void)removeDrawLayerWithId:(NSString *)uuid pageId:(NSUInteger)index;

#pragma mark - 工具类接口
- (void)settingDrawPictureTrackStyle:(DXZEducationWhiteboardTrackStyle)style;

- (void)settingDrawTrackColor:(UIColor *)color;

- (void)inputDrawTextContent:(NSString *_Nullable)content;


#pragma mark -
- (void)loadHistoryDatas:(NSArray<DrawPageDetailInfo *> *)historyDatas TotleCount:(NSUInteger)totleCount;

- (void)pageToTargetIndex:(NSUInteger)index;

- (void)createFirstWBPage;

- (void)buildNewPageAndScrollToLastIndex;

@end

NS_ASSUME_NONNULL_END
