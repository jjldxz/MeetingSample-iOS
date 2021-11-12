//
//  WhiteboardPageView.m
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/31.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "WhiteboardPageView.h"
#import "ZHFigureDrawingView.h"
#import "DrawPageHistoryDataInfo.h"
#import <YYKit/YYKit.h>

@interface WhiteboardPageView ()<ZHFigureDrawingViewActionDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *pageView;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, ZHFigureDrawingView *> *pageDatasMap;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<DrawShapeControlInfoModel *> *> *drawPageDatas;

@property (nonatomic, assign, readwrite) NSUInteger pageNo;
@property (nonatomic, assign) DXZEducationWhiteboardTrackStyle pencilTrackStyle;
@property (nonatomic, copy) UIColor *pencilTrackColor;

@end

@implementation WhiteboardPageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _drawStutes = @(YES);
        self.groupId = @(-1);
        self.pageNo = 0;
        self.backgroundColor = UIColor.whiteColor;
        self.pencilTrackStyle = DXZEducationWhiteboard_NULL;
        self.pencilTrackColor = nil;
        [self datasInit];
    }
    return self;
}

#pragma mark - 获取总页数
- (NSUInteger)getWBTotalPages {
    return self.pageDatasMap.count;
}

#pragma mark - 初始化数据
- (void)datasInit {
    self.pageDatasMap = [NSMutableDictionary dictionary];
    self.drawPageDatas = [NSMutableDictionary dictionary];
    [self addSubview:self.pageView];
}

- (void)createFirstWBPage {
    [self buildNewDrawViewWithPageId:@(1)];
}

- (ZHFigureDrawingView *)buildNewDrawViewWithPageId:(NSNumber *)pageId {
    if ([pageId isEqualToNumber:@(0)]) {
        // 创建了一个pageId 为0 的页面, error
        return nil;
    }
    ZHFigureDrawingView *drawPageView = [[ZHFigureDrawingView alloc] initWithFrame:CGRectZero];
    drawPageView.drawEnable = YES;
    drawPageView.drawingType = [self translateDrawingType:self.pencilTrackStyle];
    drawPageView.lineColor = self.pencilTrackColor;
    drawPageView.delegate = self;
    drawPageView.fontSize = self.fontSize;
    @weakify(self)
    drawPageView.drawCallback = ^(CGPoint drawAtPoint, BOOL isFinished, NSDictionary * _Nonnull drawInfo) {
        [weak_self compositeData:drawInfo Finished:isFinished];
    };
    [self.pageDatasMap setObject:drawPageView forKey:pageId];
    
    CGSize targetSize = CGSizeZero;
    if (self.width > self.height) {
        CGFloat whscale = self.width / self.height;
        if (whscale >= 16.f / 9.f) {
            targetSize = CGSizeMake(self.height * (16.f / 9.f), self.height);
        } else {
            targetSize = CGSizeMake(self.width, self.width / (16.f / 9.f));
        }
    } else {
        targetSize = CGSizeMake(self.width, self.width / (16.f / 9.f));
    }
    drawPageView.bounds = CGRectMake(0, 0, targetSize.width, targetSize.height);
    drawPageView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    
    return drawPageView;
}

- (void)buildNewPageAndScrollToLastIndex {
    if ([self buildNewDrawViewWithPageId:@(self.pageDatasMap.count + 1)]) {
        self.pageNo = self.pageDatasMap.count - 1;
        [UIView animateWithDuration:0 animations:^{
            [self.pageView performBatchUpdates:^{
                [self.pageView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            } completion:nil];
        }];
        [self performSelector:@selector(scrollToTargetPage) withObject:nil afterDelay:0.2];
    }
}

- (void)scrollToTargetPage {
    if (self.pageNo < self.pageDatasMap.count) {
        [self.pageView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageNo inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

#pragma mark - 翻页
- (void)pageToTargetIndex:(NSUInteger)index {
    if (index == _pageNo + 1) {
        return;
    }
    if (index > 0 && index <= self.pageDatasMap.count) {
        _pageNo = index - 1;
//        [self.pageView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [self performSelector:@selector(scrollToTargetPage) withObject:nil afterDelay:0.0];
    }
}

#pragma mark - 加载历史描绘数据
- (void)loadHistoryDatas:(NSArray<DrawPageDetailInfo *> *)historyDatas TotleCount:(NSUInteger)totleCount {
    if (self.pageDatasMap.count < totleCount) {
        NSUInteger i = 1;
        NSMutableArray<NSNumber *> *pageNums = [NSMutableArray arrayWithCapacity:totleCount];
        while (i <= totleCount) {
            [pageNums addObject:@(i)];
            i ++;
        }
        [pageNums removeObjectsInArray:self.pageDatasMap.allKeys];
        for (NSNumber *pageId in pageNums) {
            [self buildNewDrawViewWithPageId:pageId];
        }
        [self.pageView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
    [historyDatas enumerateObjectsUsingBlock:^(DrawPageDetailInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHFigureDrawingView *drawView = [self.pageDatasMap objectForKey:obj.pageId];
        if (obj.data.count > 0) {
            NSMutableArray *pageDatas = [self.drawPageDatas objectForKey:obj.pageId];
            if (pageDatas) {
                [pageDatas addObjectsFromArray:obj.data];
            } else {
                pageDatas = [NSMutableArray array];
                [pageDatas addObjectsFromArray:obj.data];
                [self.drawPageDatas setObject:pageDatas forKey:obj.pageId];
            }
        }
        if (drawView == nil) {
            drawView = [self buildNewDrawViewWithPageId:obj.pageId];
        }
        if ([obj.state isEqualToString:@"active"]) {
            self.pageNo = obj.pageId.unsignedIntegerValue - 1;
            if (self.drawDelegate && [self.drawDelegate respondsToSelector:@selector(whiteboardPageDidShowHistoryActiveIndex:AtGroupId:)]) {
                [self.drawDelegate whiteboardPageDidShowHistoryActiveIndex:obj.pageId.unsignedIntegerValue AtGroupId:self.groupId];
            }
        }
    }];
    [self.pageView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [self performSelector:@selector(scrollToTargetPage) withObject:nil afterDelay:0.0];
}

#pragma mark - 释放缓存
- (void)releaseResource {
    [self.pageDatasMap removeAllObjects];
    [self.drawPageDatas removeAllObjects];
    self.drawDelegate = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:ZHFigureDrawingView.class]) {
            ZHFigureDrawingView *drawView = (ZHFigureDrawingView *)obj;
            [drawView releaseSourceDatas];
        }
    }];
    [self removeAllSubviews];
    [self removeFromSuperview];
}

#pragma mark - 设置当前画板的绘画状态
- (void)setDrawStutes:(NSNumber *)drawStutes {
    if (_drawStutes != drawStutes) {
        [NSObject willChangeValueForKey:@"drawStutes"];
        _drawStutes = drawStutes;
        [NSObject didChangeValueForKey:@"drawStutes"];
        [self.pageDatasMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, ZHFigureDrawingView * _Nonnull obj, BOOL * _Nonnull stop) {
            obj.drawEnable = drawStutes.boolValue;
        }];
    }
}

- (void)revokeOperationWithModel:(DrawPageRevokeInfoModel *)model {
    NSInteger pageIndex = model.pageId.integerValue - 1;
    if (pageIndex >= 0 && pageIndex < self.pageDatasMap.count) {
        ZHFigureDrawingView *drawView = [self.pageDatasMap objectForKey:model.pageId];
        [drawView revokeTargerOperation:model];
    }
}

#pragma mark - 创建空白画板
- (void)removeDrawPageWithIndex:(NSUInteger)index {
    if (index >= 0 && index < self.pageDatasMap.count) {
        if (index <= self.pageNo) {
            self.pageNo -= 1;
        }
        ZHFigureDrawingView *drawView = [self.pageDatasMap objectForKey:@(index + 1)];
        [drawView removeFromSuperview];
        [self.pageDatasMap removeObjectForKey:@(index + 1)];
    }
    [self pageToTargetIndex:index + 1];
}

- (void)removeDrawLayerWithId:(NSString *)uuid pageId:(NSUInteger)index {
    if (index >= 0 && index < self.pageDatasMap.count) {
        ZHFigureDrawingView *drawView = [self.pageDatasMap objectForKey:@(index + 1)];
        [drawView removePageLayerWithId:uuid];
    }
}

#pragma mark - 描绘铅笔工具数据
- (void)pencilDrawInViewWithInfo:(DrawLineControlInfoModel *)model {
    ZHFigureDrawingView *drawView = [self.pageDatasMap objectForKey:model.pageId];
    if (drawView) {
        [drawView beginDrawLinePicWithModel:model];
    }
}

#pragma mark - 描绘其他图形数据
- (void)shapeDrawInViewWithOperation:(DrawShapeControlInfoModel *)model {
    ZHFigureDrawingView *drawView = [self.pageDatasMap objectForKey:model.pageId];
    if (drawView) {
        [drawView beginDrawShapWithModel:model];
    }
}

#pragma mark - 数据序列化处理(model类型转换)
- (void)compositeData:(NSDictionary *)drawDataInfo Finished:(BOOL)finished {
    NSMutableString *sendMessage = [NSMutableString string];
    NSNumber *drawType = [drawDataInfo objectForKey:@"drawType"];
    NSString *startPoint = [drawDataInfo objectForKey:@"start_point"];
    NSString *endtPoint = [drawDataInfo objectForKey:@"end_point"];
    NSString *pageUuid = [drawDataInfo objectForKey:@"uuid"];
    NSString *lineColor = [drawDataInfo objectForKey:@"lineColor"];
    NSNumber *lineWidth = [drawDataInfo objectForKey:@"lineWidth"];
    NSNumber *timeInterval = [drawDataInfo objectForKey:@"time"];
    switch ([drawType unsignedIntegerValue]) {
        case ZHFigureDrawingTypeGraffiti: {
            DrawLineControlInfoModel *model = [DrawLineControlInfoModel sendRTMPointInfoWithGroupId:self.groupId PageId:@(self.pageNo + 1) LineColor:lineColor StartPointSit:CGPointFromString(endtPoint) DrawType:@"drw_line"];
            model.finish = finished;
            model.Id = pageUuid;
            model.lineWidth = [lineWidth floatValue];
            model.time = (long)([timeInterval doubleValue] * 1000);
            NSDictionary *jsonDict = [model modelToJSONObject];
            [jsonDict setValue:pageUuid forKey:@"id"];
            [jsonDict setValue:self.groupId forKey:@"groupId"];
            [sendMessage appendString:[jsonDict jsonStringEncoded]];
        } break;
        default: {
            NSMutableString *type = [NSMutableString string];
            if ([drawType unsignedIntegerValue] == ZHFigureDrawingTypeLine) {
                [type appendString:@"drw_straight_line"];
            } else if ([drawType unsignedIntegerValue] == ZHFigureDrawingTypeCircle) {
                [type appendString:@"drw_round"];
            } else if ([drawType unsignedIntegerValue] == ZHFigureDrawingTypeRect) {
                [type appendString:@"drw_rect"];
            } else if ([drawType unsignedIntegerValue] == ZHFigureDrawingTypeText) {
                [type appendString:@"drw_text"];
                
            }
            DrawShapeControlInfoModel *model = [DrawShapeControlInfoModel sendShapeRTMMessageModelWithType:type groupId:self.groupId lineColor:lineColor lineWidth:[lineWidth floatValue]];
            model.pageId = @(self.pageNo + 1);
            model.finish = finished;
            CGPoint start_p = CGPointFromString(startPoint);
            DrawPointModel *start_model = [DrawPointModel new];
            start_model.x = start_p.x;
            start_model.y = start_p.y;
            model.startDot = start_model;
            CGPoint end_p = CGPointFromString(endtPoint);
            DrawPointModel *end_model = [DrawPointModel new];
            end_model.x = end_p.x;
            end_model.y = end_p.y;
            model.endDot = end_model;
            model.time = (long)([timeInterval doubleValue] * 1000);
            model.type = [type copy];
            if ([drawType unsignedIntegerValue] == ZHFigureDrawingTypeText) {
                model.content = [drawDataInfo objectForKey:@"content"];
                model.textW = [[drawDataInfo objectForKey:@"textW"] doubleValue];
                model.textH = [[drawDataInfo objectForKey:@"textH"] doubleValue];
            }
            NSDictionary *jsonDict = [model modelToJSONObject];
            [jsonDict setValue:pageUuid forKey:@"id"];
            [jsonDict setValue:self.groupId forKey:@"groupId"];
            [sendMessage appendString:[jsonDict jsonStringEncoded]];
        } break;
    }
    if (self.drawDelegate && [self.drawDelegate respondsToSelector:@selector(sendDrawActionJsonStringDatas:)]) {
        [self.drawDelegate sendDrawActionJsonStringDatas:sendMessage];
    }
}

#pragma mark - 加载历史撤销数据
- (void)loadHistoryRevokeInfo:(DrawShapeControlInfoModel *)model {
//    if ([model.groupId isEqualToNumber:@(-1)]) {
//        
//    } else {
//        self.courseInfo
//    }
}

#pragma mark - ZHFigureDrawingViewActionDelegate
- (void)drawingViewClearAll:(NSString *)Id {
    NSMutableDictionary *clearInformation = [NSMutableDictionary dictionary];
    [clearInformation setObject:@"msg_drawing" forKey:@"kind"];
    [clearInformation setObject:@"drw_clearall" forKey:@"type"];
    [clearInformation setObject:self.groupId forKey:@"groupId"];
    [clearInformation setObject:@(self.pageNo + 1) forKey:@"pageId"];
    [clearInformation setObject:Id forKey:@"id"];
    [clearInformation setObject:@((long)([NSDate date].timeIntervalSince1970 * 1000)) forKey:@"time"];
    NSString *jsonString = [clearInformation jsonStringEncoded];
    if (self.drawDelegate && [self.drawDelegate respondsToSelector:@selector(sendDrawActionJsonStringDatas:)]) {
        [self.drawDelegate sendDrawActionJsonStringDatas:jsonString];
    }
}

#pragma mark - 撤销上一步数据描绘
- (void)drawingViewPreviousStepWithModel:(DXZEducationRevokeInfoModel *)model {
    for (CALayer *layer in model.drawViews) {
        NSMutableDictionary *clearInformation = [NSMutableDictionary dictionary];
        if ([layer isKindOfClass:ZHFigureDrawingLayer.class]) {
            ZHFigureDrawingLayer *drawLayer = (ZHFigureDrawingLayer *)layer;
            [clearInformation setObject:drawLayer.uuid forKey:@"targetId"];
        } else {
            ZHDTextLayer *textLayer = (ZHDTextLayer *)layer;
            [clearInformation setObject:textLayer.uuid forKey:@"targetId"];
        }
        [clearInformation setObject:@"msg_drawing" forKey:@"kind"];
        [clearInformation setObject:@"drw_revoke" forKey:@"type"];
        [clearInformation setObject:self.groupId forKey:@"groupId"];
        [clearInformation setObject:@(self.pageNo + 1) forKey:@"pageId"];
        [clearInformation setObject:model.Id forKey:@"id"];
        
        NSString *jsonString = [clearInformation jsonStringEncoded];
        if (self.drawDelegate && [self.drawDelegate respondsToSelector:@selector(sendDrawActionJsonStringDatas:)]) {
            [self.drawDelegate sendDrawActionJsonStringDatas:jsonString];
        }
    }
}

#pragma mark - 删除指定uuid数据
- (void)drawingViewDeleteWithId:(NSString *)uuid TargetId:(NSString *)targetId {
    NSMutableDictionary *clearInformation = [NSMutableDictionary dictionary];
    [clearInformation setObject:@"msg_drawing" forKey:@"kind"];
    [clearInformation setObject:@"drw_delete" forKey:@"type"];
    [clearInformation setObject:self.groupId forKey:@"groupId"];
    [clearInformation setObject:@(self.pageNo + 1) forKey:@"pageId"];
    [clearInformation setObject:uuid forKey:@"id"];
    [clearInformation setObject:@((long)([NSDate date].timeIntervalSince1970 * 1000)) forKey:@"time"];
    [clearInformation setObject:@(YES) forKey:@"finish"];
    [clearInformation setObject:targetId forKey:@"targetId"];
    NSString *jsonString = [clearInformation jsonStringEncoded];

    if (self.drawDelegate && [self.drawDelegate respondsToSelector:@selector(sendDrawActionJsonStringDatas:)]) {
        [self.drawDelegate sendDrawActionJsonStringDatas:jsonString];
    }
}

#pragma mark - 工具操作
- (void)nextStepOnCurrentPage {
    if (self.pageNo < self.pageDatasMap.count) {
        ZHFigureDrawingView *layerView = [self.pageDatasMap objectForKey:@(self.pageNo + 1)];
        [layerView nextStep];
    } else {
        if (self.pageDatasMap.count == 0) {
            self.pageNo = 0;
            [self buildNewPageAndScrollToLastIndex];
        }
    }
}

- (void)previousStepOnCurrentPage {
    if (self.pageNo < self.pageDatasMap.count) {
        ZHFigureDrawingView *layerView = [self.pageDatasMap objectForKey:@(self.pageNo + 1)];
        [layerView previousStep];
    } else {
        if (self.pageDatasMap.count == 0) {
            self.pageNo = 0;
            [self buildNewPageAndScrollToLastIndex];
        }
    }
}

- (void)removeAllLayerDrawingOnCurrentPage {
    if (self.pageNo < self.pageDatasMap.count) {
        ZHFigureDrawingView *layerView = [self.pageDatasMap objectForKey:@(self.pageNo + 1)];
        [layerView removeAllLayerDrawing];
    } else {
        if (self.pageDatasMap.count == 0) {
            self.pageNo = 0;
            [self buildNewPageAndScrollToLastIndex];
        }
    }
}

- (void)rotateAllLayerDrawingOnCurrentPage {
    if (self.pageNo < self.pageDatasMap.count) {
        ZHFigureDrawingView *layerView = [self.pageDatasMap objectForKey:@(self.pageNo + 1)];
        [layerView rotateAllLayerDrawing];
    } else {
       if (self.pageDatasMap.count == 0) {
           self.pageNo = 0;
           [self buildNewPageAndScrollToLastIndex];
       }
    }
}

#pragma mark - 功能操作
- (void)settingDrawPictureTrackStyle:(DXZEducationWhiteboardTrackStyle)style {
    self.pencilTrackStyle = style;
    ZHFigureDrawingType currentDrawType = ZHFigureDrawingTypeNULL;
    switch (style) {
        case DXZEducationWhiteboard_Graffiti_Tool:
            currentDrawType = ZHFigureDrawingTypeGraffiti; break;
        case DXZEducationWhiteboard_Line_Tool:
            currentDrawType = ZHFigureDrawingTypeLine; break;
        case DXZEducationWhiteboard_Rect_Tool:
            currentDrawType = ZHFigureDrawingTypeRect; break;
        case DXZEducationWhiteboard_Circle_Tool:
            currentDrawType = ZHFigureDrawingTypeCircle; break;
        case DXZEducationWhiteboard_Text_Tool:
            currentDrawType = ZHFigureDrawingTypeText; break;
        case DXZEducationWhiteboard_NULL:
            currentDrawType = ZHFigureDrawingTypeNULL; break;
        case DXZEducationWhiteboard_Clear_Tools:
            break;
        case DXZEducationWhiteboard_Revoke_Tools:
            break;
        case DXZEducationWhiteboard_Color_Tools:
            break;
    }
    [self.pageDatasMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, ZHFigureDrawingView * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.drawingType = currentDrawType;
    }];
}

#pragma mark - 设置画笔颜色
- (void)settingDrawTrackColor:(UIColor *)color {
    self.pencilTrackColor = color.copy;
    //添加测试代码
    [self.pageDatasMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, ZHFigureDrawingView * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.lineColor = color.copy;
    }];
}

#pragma mark - 设置文字内容
- (void)inputDrawTextContent:(NSString *)content {
    if (self.pageNo < self.pageDatasMap.count) {
        ZHFigureDrawingView *layerView = [self.pageDatasMap objectForKey:@(self.pageNo + 1)];
        [layerView drawTextInTheWBPage:content];
    }
}

- (ZHFigureDrawingType)translateDrawingType:(DXZEducationWhiteboardTrackStyle)style {
    switch (style) {
        case DXZEducationWhiteboard_Graffiti_Tool:
            return ZHFigureDrawingTypeGraffiti; break;
        case DXZEducationWhiteboard_Line_Tool:
            return ZHFigureDrawingTypeLine; break;
        case DXZEducationWhiteboard_Rect_Tool:
            return ZHFigureDrawingTypeRect; break;
        case DXZEducationWhiteboard_Circle_Tool:
            return ZHFigureDrawingTypeCircle; break;
        case DXZEducationWhiteboard_Text_Tool:
            return ZHFigureDrawingTypeText; break;
        case DXZEducationWhiteboard_NULL:
            return ZHFigureDrawingTypeNULL; break;
        default:
            return ZHFigureDrawingTypeNULL; break;
    }
}

#pragma mark - <================== test code ==================>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pageDatasMap.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kDXZWBPAGEVIEWCELL" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell.contentView removeAllSubviews];
    NSNumber *pageId = @(indexPath.row + 1);
    ZHFigureDrawingView *drawView = [self.pageDatasMap objectForKey:pageId];
    if (drawView == nil) {
        drawView = [self buildNewDrawViewWithPageId:pageId];
    }
    [cell.contentView addSubview:drawView];
    
    if ([self.drawPageDatas objectForKey:pageId]) {
        NSMutableArray<DrawShapeControlInfoModel *> *historyDatas = [self.drawPageDatas objectForKey:pageId];
        [historyDatas enumerateObjectsUsingBlock:^(DrawShapeControlInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.type isEqualToString:@"drw_line"]) {
                DrawLineControlInfoModel *lineModel = [DrawLineControlInfoModel modelWithJSON:[obj modelToJSONObject]];
                [drawView beginDrawLinePicWithModel:lineModel];
            } else {
                [drawView beginDrawShapWithModel:obj];
            }
        }];
        [self.drawPageDatas removeObjectForKey:pageId];
    }
}

#pragma mark - lazy load
- (UICollectionView *)pageView {
    if (_pageView == nil) {
        UICollectionViewFlowLayout *layouts = [UICollectionViewFlowLayout new];
        layouts.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layouts.itemSize = self.bounds.size;
        _pageView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layouts];
        _pageView.delegate = self;
        _pageView.dataSource = self;
        _pageView.scrollEnabled = NO;
        [_pageView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"kDXZWBPAGEVIEWCELL"];
        _pageView.backgroundColor = UIColor.whiteColor;
    }
    return _pageView;
}

#pragma mark - dealloc
- (void)dealloc {
    [self removeAllSubviews];
}

@end
