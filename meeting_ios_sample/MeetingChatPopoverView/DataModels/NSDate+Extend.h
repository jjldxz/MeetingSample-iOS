//
//  NSDate+Extend.h
//  meeting_iOS
//
//  Created by HYWD on 2021/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Extend)
/**两个Date之间的比较*/
- (NSDateComponents *)intervalToDate:(NSDate *)date;
/**与当前时间比较*/
- (NSDateComponents *)intervalToNow;
@end

NS_ASSUME_NONNULL_END
