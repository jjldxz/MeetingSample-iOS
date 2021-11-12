//
//  WhiteboardToolsModel.m
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/17.
//

#import "WhiteboardToolsModel.h"

@implementation WhiteboardToolsModel

DXZLvbWhiteboardTypeEnum dxzLvbWBDrwTypeTansform(NSString *drwType) {
    if ([drwType isEqualToString:@"drw_line"]) {
        return DXZLvbWhiteboardType_DRW_LINE;
    } else if ([drwType isEqualToString:@"drw_straight_line"]) {
        return DXZLvbWhiteboardType_DRW_STRAIGHT_LINE;
    } else if ([drwType isEqualToString:@"drw_rect"]) {
        return DXZLvbWhiteboardType_DRW_RECT;
    } else if ([drwType isEqualToString:@"drw_round"]) {
        return DXZLvbWhiteboardType_DRW_ROUND;
    } else if ([drwType isEqualToString:@"drw_text"]) {
        return DXZLvbWhiteboardType_DRW_TEXT;
    } else if ([drwType isEqualToString:@"drw_image"]) {
        return DXZLvbWhiteboardType_DRW_IMAGE;
    } else if ([drwType isEqualToString:@"drw_del_image"]) {
        return DXZLvbWhiteboardType_DRW_DEL_IMAGE;
    } else if ([drwType isEqualToString:@"drw_delete"]) {
        return DXZLvbWhiteboardType_DRW_DELETE;
    } else if ([drwType isEqualToString:@"drw_clearall"]) {
        return DXZLvbWhiteboardType_DRW_CLEARALL;
    } else if ([drwType isEqualToString:@"drw_revoke"]) {
        return DXZLvbWhiteboardType_DRW_REVOKE;
    } else if ([drwType isEqualToString:@"drw_revoke_on"]) {
        return DXZLvbWhiteboardType_DRW_REVOKE_ON;
    } else if ([drwType isEqualToString:@"drw_revoke_off"]) {
        return DXZLvbWhiteboardType_DRW_REVOKE_OFF;
    } else if ([drwType isEqualToString:@"drw_page"]) {
        return DXZLvbWhiteboardType_DRW_PAGE;
    } else if ([drwType isEqualToString:@"drw_page_change"]) {
        return DXZLvbWhiteboardType_DRW_PAGE_CHANGE;
    } else if ([drwType isEqualToString:@"drw_page_delete"]) {
        return DXZLvbWhiteboardType_DRW_PAGE_DELETE;
    }  else if ([drwType isEqualToString:@"ctl_update"]) {
        return DXZLvbWhiteboardType_DRW_HISTORY;
    } else {
        return DXZLvbWhiteboardType_NULL;
    }
}

@end
