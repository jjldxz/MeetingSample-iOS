//
//  RootNavigationController.m
//  dxz_class_room
//
//  Created by HYWD on 2021/1/7.
//  Copyright © 2021 DXZVideoGroup. All rights reserved.
//

#import "RootNavigationController.h"
#import "meeting_ios_sample-Swift.h"

@interface RootNavigationController ()
//屏幕旋转权限
@property (nonatomic, assign) UIInterfaceOrientationMask faceOrientationMask;
@property (nonatomic,strong) UIViewController *viewController;
@end

@implementation RootNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:rootViewController])
    {
        [self.navigationBar setBackgroundImage:[[UIImage alloc] init]  forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [[UIImage alloc] init];
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#666666"],NSFontAttributeName:[UIFont systemFontOfSize:18.f]};
        self.view.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    self.viewController = viewController;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"meeting_Back_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]style:UIBarButtonItemStylePlain target:self action:@selector(popToPre)];
    viewController.navigationItem.leftBarButtonItem = leftItem;
    viewController.navigationItem.hidesBackButton = YES;
    viewController.hidesBottomBarWhenPushed = YES;

}

- (void)popToPre {
    if ([ self.viewController isKindOfClass:VoteResultController.class] ) {
        self.viewController = VoteListViewController.new;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"popToPreR" object:nil];
    }else if ([ self.viewController isKindOfClass:UserResultController.class] ) {
        self.viewController = VoteListViewController.new;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"popToPreR" object:nil];
    }else if([ self.viewController isKindOfClass:VotePublishViewController.class]){
        self.viewController = VoteListViewController.new;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"popToPrev" object:nil];
    }else{
        [self popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"popToPre" object:nil];
    }
    
}

@end
