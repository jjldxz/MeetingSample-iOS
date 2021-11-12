//
//  WhiteboardToolsModel.h
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DXZLvbWhiteboardTypeEnum) {
    DXZLvbWhiteboardType_NULL,
    DXZLvbWhiteboardType_DRW_LINE,
    DXZLvbWhiteboardType_DRW_STRAIGHT_LINE,
    DXZLvbWhiteboardType_DRW_RECT,
    DXZLvbWhiteboardType_DRW_ROUND,
    DXZLvbWhiteboardType_DRW_TEXT,
    DXZLvbWhiteboardType_DRW_IMAGE,
    DXZLvbWhiteboardType_DRW_DEL_IMAGE,
    DXZLvbWhiteboardType_DRW_DELETE,
    DXZLvbWhiteboardType_DRW_CLEARALL,
    DXZLvbWhiteboardType_DRW_REVOKE,
    DXZLvbWhiteboardType_DRW_REVOKE_ON,
    DXZLvbWhiteboardType_DRW_REVOKE_OFF,
    DXZLvbWhiteboardType_DRW_PAGE,
    DXZLvbWhiteboardType_DRW_PAGE_CHANGE,
    DXZLvbWhiteboardType_DRW_PAGE_DELETE,
    DXZLvbWhiteboardType_DRW_HISTORY
};

typedef NS_ENUM(NSUInteger, DXZEducationWhiteboardTrackStyle) {
    DXZEducationWhiteboard_NULL,
    DXZEducationWhiteboard_Graffiti_Tool,
    DXZEducationWhiteboard_Line_Tool,
    DXZEducationWhiteboard_Rect_Tool,
    DXZEducationWhiteboard_Circle_Tool,
    DXZEducationWhiteboard_Text_Tool,
    DXZEducationWhiteboard_Clear_Tools,
    DXZEducationWhiteboard_Revoke_Tools,
    DXZEducationWhiteboard_Color_Tools
};

@interface WhiteboardToolsModel : NSObject

DXZLvbWhiteboardTypeEnum dxzLvbWBDrwTypeTansform(NSString *drwType);

@end

NS_ASSUME_NONNULL_END
