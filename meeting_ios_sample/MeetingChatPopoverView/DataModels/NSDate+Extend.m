//
//  NSDate+Extend.m
//  meeting_iOS
//
//  Created by HYWD on 2021/7/10.
//

#import "NSDate+Extend.h"

@implementation NSDate (Extend)
// 得到的结果如下图（可用作判断会话时间显示：例如：几分钟之前，今天，昨天 等

- (NSDateComponents *)intervalToDate:(NSDate *)date
{
      // 日历对象
    NSCalendar *calender = [NSCalendar currentCalendar];
    
    // 获得一个时间元素
    NSCalendarUnit  unit =  NSCalendarUnitYear | NSCalendarUnitMonth
    | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond;
   
    return [calender components:unit fromDate:self toDate:date options:kNilOptions];
}
- (NSDateComponents *)intervalToNow
{
    return [self intervalToDate:[NSDate date]];
}

// 得到的结果为相差的天数
- (int)intervalSinceNow:(NSString *) theDate
{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    // 这里的格式根据自己的需要自行确定（yyyy-MM-dd hh:mm:ss）
    [date setDateFormat:@"yyyy-MM-dd"];
    NSDate *d=[date dateFromString:theDate];
    
    NSInteger unitFlags = NSCalendarUnitDay| NSCalendarUnitMonth | NSCalendarUnitYear;
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [cal components:unitFlags fromDate:d];
    NSDate *newBegin  = [cal dateFromComponents:comps];

    // 当前时间
    NSCalendar *cal2 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps2 = [cal2 components:unitFlags fromDate:[NSDate date]];
    NSDate *newEnd  = [cal2 dateFromComponents:comps2];

    
    NSTimeInterval interval = [newEnd timeIntervalSinceDate:newBegin];
    NSInteger resultDays=((NSInteger)interval)/(3600*24);
    
    return (int) resultDays;
}
@end
