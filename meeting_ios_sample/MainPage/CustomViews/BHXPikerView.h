//
//  TXTimeChoose.h
//  TYSubwaySystem
//
//  Created by mac on 16/7/18.
//  Copyright © 2016年 TXZhongJiaowang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit/YYKit.h>

#define kZero 0
#define HexColor(hex) ([UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00)  >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0])
#define kDatePicHeight 200

#define kStatusBarH \
({\
    @available(iOS 13.0, *) ? [[[UIApplication sharedApplication] windows] objectAtIndex:0].windowScene.statusBarManager.statusBarFrame.size.height : [[UIApplication sharedApplication] statusBarFrame].size.height;\
})

#define kBottomSafeH ([UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom)

#define kDatePicY (kScreenHeight - kBottomSafeH - kDatePicHeight)

#define kDateTopBtnY kDatePicY - 30
#define kDateTopBtnHeight 40

#define kDateTopLeftbtnX 30

#define kDateTopLeftBtnWidth 80

#define kDateTopRightBtnWidth kDateTopLeftBtnWidth
#define kDateTopRightBtnX kScreenWidth - 30 - kDateTopRightBtnWidth
#define CurrentLanguages [NSLocale preferredLanguages][0]

#define kLineColors HexColor(0xEEEEEE)


@class BHXPikerView;

@protocol BHXDatePikerViewDelegate <NSObject>
//必须实现的两个代理
@required
//当时间改变时触发
//- (void)changeTime:(NSDate *)date;
//确定时间
- (void)timeView:(BHXPikerView *)view determine:(NSDate *)date;

@end


@protocol BHXPickerViewDelegate <NSObject>

//改变时触发
- (void)changeDate:(NSString *)dateString andComponent:(NSInteger)component;
//确定时触发
- (void)deterDate:(NSString *)dateString andComponent:(NSInteger)component;

@end


@interface BHXPikerView : UIView

@property (nonatomic,strong)UIDatePicker *dateP;

//初始化方法
- (instancetype)initWithFrame:(CGRect)frame type:(UIDatePickerMode)type;

- (instancetype)initWithFrame:(CGRect)frame andArray:(NSArray *)array;


//设置初始时间
- (void)setNowTime:(NSString *)dateStr;

// NSDate --> NSString
- (NSString*)stringFromDate:(NSDate*)date;
//NSDate <-- NSString
- (NSDate*)dateFromString:(NSString*)dateString;

- (void)handleDateTopViewCancel;
- (void)handleDateTopViewCertain;
- (void)handleDateTopViewCertain1;


@property (assign,nonatomic)id<BHXDatePikerViewDelegate>delegate;

@property (assign,nonatomic)id<BHXPickerViewDelegate>pickerdelegate;

@end
