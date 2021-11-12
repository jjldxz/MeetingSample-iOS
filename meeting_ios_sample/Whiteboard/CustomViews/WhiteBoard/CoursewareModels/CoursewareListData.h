//
//  CoursewareListData.h
//  AgoraEducation
//
//  Created by FoxDog on 2020/3/31.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoursewareDetailInfoModel : NSObject<NSCopying>

@property (nonatomic, copy) NSString *cos_path;
@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSNumber *height;

@end

@interface CoursewareListData : NSObject

@property (nonatomic, copy) NSNumber *Id;
@property (nonatomic, copy) NSString *name;
@property (copy, nonatomic) NSString *size;
@property (copy, nonatomic) NSString *status;
@property (assign, nonatomic) BOOL is_delete;
@property (nonatomic, copy) NSArray<CoursewareDetailInfoModel *> *pic_list;

@end

NS_ASSUME_NONNULL_END
