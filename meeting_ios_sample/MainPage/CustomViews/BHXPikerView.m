//
//  TXTimeChoose.m
//  TYSubwaySystem
//
//  Created by mac on 16/7/18.
//  Copyright © 2016年 TXZhongJiaowang. All rights reserved.
//

#import "BHXPikerView.h"

@interface BHXPikerView()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSString *contentString;
    NSInteger commentRow;
}

@property (nonatomic,strong)UIPickerView *pickerView;
@property (nonatomic,strong)UIButton *leftBtn;
@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)UIView *topView;
@property (nonatomic,strong)UIView *groundV;

@property (nonatomic,assign)UIDatePickerMode type;

@property (strong, nonatomic) NSArray *array;
@end

@implementation BHXPikerView
- (instancetype)initWithFrame:(CGRect)frame type:(UIDatePickerMode)type{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self addSubview:self.groundV];
        [self addSubview:self.dateP];
        [self addSubview:self.topView];
        [self addSubview:self.leftBtn];
        [self addSubview:self.rightBtn];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andArray:(NSArray *)array{
    self = [super initWithFrame:frame];
    if (self) {
        self.array = array;
        [self addSubview:self.pickerView];
        [self addSubview:self.topView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _pickerView.frame = CGRectMake(0, kDatePicY, kScreenWidth, kDatePicHeight);
    _dateP.frame = CGRectMake(0, kDatePicY, kScreenWidth, kDatePicHeight);
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        UIPickerView *pickView=[[UIPickerView alloc] init];
        pickView.backgroundColor=[UIColor whiteColor];
        _pickerView=pickView;
        pickView.delegate=self;
        pickView.dataSource=self;
        pickView.frame = CGRectMake(0, kDatePicY, kScreenWidth, kDatePicHeight);
        [self addSubview:pickView];
    }
    return _pickerView;
}

- (UIDatePicker *)dateP{
    if (!_dateP) {
        self.dateP = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, kDatePicY, kScreenWidth, kDatePicHeight)];
        [self.dateP setValue:UIColor.blackColor forKey:@"textColor"];
        self.dateP.backgroundColor = [UIColor whiteColor];
        [self.dateP setLocale:[NSLocale systemLocale]];
        self.dateP.datePickerMode = self.type;
        if (@available(iOS 13.4, *)) {
            [self.dateP setPreferredDatePickerStyle:UIDatePickerStyleWheels];
        } else {
            // Fallback on earlier versions
        }
        self.dateP.locale = [[NSLocale alloc]initWithLocaleIdentifier:CurrentLanguages];
   
        [self.dateP addTarget:self action:@selector(handleDateP:) forControlEvents:UIControlEventValueChanged];

    }
    return _dateP;
}

- (UIView *)topView {
    if (!_topView) {
        self.topView = [[UIView alloc]initWithFrame:CGRectMake(kZero, kDateTopBtnY, kScreenWidth, kDateTopBtnHeight)];
        self.topView.backgroundColor = kLineColors;
    }
    return _topView;
}
- (UIButton *)leftBtn{
    if (!_leftBtn) {
        self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.leftBtn.frame = CGRectMake(kDateTopLeftbtnX, kDateTopBtnY, kDateTopLeftBtnWidth, kDateTopBtnHeight);
        [self.leftBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.leftBtn addTarget:self action:@selector(handleDateTopViewLeft) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightBtn.frame = CGRectMake(kDateTopRightBtnX, kDateTopBtnY, kDateTopRightBtnWidth, kDateTopBtnHeight);
        [self.rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.rightBtn setTitle:@"Ok" forState:UIControlStateNormal];
        
        [self.rightBtn addTarget:self action:@selector(handleDateTopViewRight) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}
-(void)handleDateTopViewLeft {
    [self end];
}

- (void)handleDateTopViewRight {
    [self.delegate timeView:self determine:self.dateP.date];
    [self end];
}

- (UIView *)groundV {
    if (!_groundV) {
        self.groundV = [[UIView alloc]initWithFrame:self.bounds];
        self.groundV.backgroundColor = [UIColor whiteColor];
        self.groundV.alpha = 0.7;
    }
    return _groundV;
}


- (void)setNowTime:(NSString *)dateStr{
    [self.dateP setDate:[self dateFromString:dateStr] animated:YES];
}

- (void)end{
    [self removeFromSuperview];
}

- (void)handleDateP :(NSDate *)date {
    
//    [self.delegate changeTime:self.dateP.date];
}

- (void)handleDateTopViewCancel {
    [self end];
}
#pragma mark - 时间控件datePicker的数据传递
- (void)handleDateTopViewCertain {
    [self.delegate timeView:self determine:self.dateP.date];
    [self end];
}
#pragma mark - 自定义数据传递
- (void)handleDateTopViewCertain1 {
    
    [self.pickerdelegate deterDate:contentString andComponent:commentRow];
    contentString = nil;
    [self end];
}



// NSDate --> NSString
- (NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *dateFormatter0 = [[NSDateFormatter alloc] init];
    if ([CurrentLanguages containsString:@"zh-"]) {
        [dateFormatter0 setDateFormat:@"yyyy年MM月dd日"];
    }else{
        [dateFormatter0 setDateFormat:@"yyyy-MM-dd"];
    }
    NSString *destDateString0 = [dateFormatter0 stringFromDate:date];
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"EEE"];
    NSString *destDateString1 = [dateFormatter1 stringFromDate:date];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"HH:mm"];
    NSString *destDateString2 = [dateFormatter2 stringFromDate:date];
    
    return [NSString stringWithFormat:@"%@ %@ %@",destDateString0,destDateString1,destDateString2];
}

//转换中英文
-(NSString *)theChangeWeek:(NSString *)theWeek{
    NSString *Str;
    if(theWeek){
        if([theWeek isEqualToString:@"周一"]){
            Str = @"Monday";
        }else if([theWeek isEqualToString:@"周二"]){
            Str = @"Tuesday";
        }else if([theWeek isEqualToString:@"周三"]){
            Str = @"Wednesday";
        }else if([theWeek isEqualToString:@"周四"]){
            Str = @"Thursday";
        }else if([theWeek isEqualToString:@"周五"]){
            Str = @"Friday";
        }else if([theWeek isEqualToString:@"周六"]){
            Str = @"Saturday";
        }else if([theWeek isEqualToString:@"周日"]){
            Str = @"Sunday";
        }
    }
    return Str;
}

//NSDate <-- NSString
- (NSDate*)dateFromString:(NSString*)dateString{
    
    NSString *changeStr = [dateString substringToIndex:11];
    if ([CurrentLanguages containsString:@"zh-"]) {
        changeStr = [changeStr stringByReplacingOccurrencesOfString:@"年" withString:@"-"];
        changeStr = [changeStr stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
        changeStr = [changeStr stringByReplacingOccurrencesOfString:@"日" withString:@""];
    }else{
        changeStr = [changeStr stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    }

    
    dateString = [dateString stringByReplacingOccurrencesOfString:[dateString substringToIndex:11] withString:changeStr];
    
//    dateString = [dateString stringByReplacingOccurrencesOfString:[[dateString componentsSeparatedByString:@" "] objectAtIndex:1] withString:[[dateString componentsSeparatedByString:@" "] objectAtIndex:1]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    switch (self.type) {
        case UIDatePickerModeTime:
            [dateFormatter setDateFormat:@"hh:mm"];
            break;
        case UIDatePickerModeDate:
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            break;
        case UIDatePickerModeDateAndTime:
            [dateFormatter setDateFormat:@"yyyy-MM-dd EEEE HH:mm"];
            break;
        case UIDatePickerModeCountDownTimer:
            [dateFormatter setDateFormat:@"hh:mm"];
            break;
        default:
            break;
    }
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
}


#pragma mark piackView 数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.array.count;
}

#pragma mark UIPickerViewdelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    contentString = self.array[row];
    commentRow = row;
    return self.array[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    contentString = self.array[row];
    commentRow = row;

    [self.pickerdelegate changeDate:self.array[row] andComponent:row];
}

@end

