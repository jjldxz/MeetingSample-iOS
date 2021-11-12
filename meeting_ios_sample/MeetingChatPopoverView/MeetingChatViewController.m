//
//  MeetingChatViewController.m
//  meeting_iOS
//
//  Created by HYWD on 2021/8/11.
//

#import "MeetingChatViewController.h"
#import "meeting_ios_sample-Swift.h"

@interface MeetingChatViewController ()<MeetChatRoomViewDelegate>

@property (weak, nonatomic) SampleMeetingManager *manager;
@property (strong, nonatomic) RoomUserInfoModel *info;

@end

@implementation MeetingChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.title = @"Chat";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStylePlain target:self action:@selector(closeViewAction)];
    [self.view addSubview:self.chatView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)closeViewAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingManager:(__weak id)manager {
    self.manager = (SampleMeetingManager *)manager;
}

- (void)settingCurrentUserInfoMap:(NSDictionary *)info_map {
    if (info_map) {
        self.info = [RoomUserInfoModel modelWithDictionary:info_map];
        self.info.user_ext_id = [info_map[@"user_id"] intValue] ?: 0;
    }
}

- (void)receivedMeetingChatMessage:(MeetingChatMessageDataModel *)data {
    if (data) {
        [self.chatView addChatMessage:data];
    }
}

///MeetChatRoomViewDelegate
#pragma mark - MeetChatRoomViewDelegate
- (void)meetChatRoomView:(MeetChatRoomView *)chatRoom DidUserInputText:(NSString *)text userInfo:(RoomUserInfoModel *)userInfo {
    if (text && ![text isEqualToString:@""]) {
        if (_delegate && [_delegate respondsToSelector:@selector(meetingChatPopoverView:UserDidInputChatMessage:userId:)]) {
            MeetingChatMessageDataModel *data = [_delegate meetingChatPopoverView:self UserDidInputChatMessage:text userId:@(userInfo.user_ext_id)];
            data.toUid = @(userInfo.user_ext_id).stringValue;
            data.toUser_name = userInfo.name;
            data.messageDate = [NSDate date];
            [chatRoom addChatMessage:data];
        }
    }
}

- (void)meetChatRoomViewChoseUserList:(MeetChatRoomView *)chatRoom{
    
}

- (MeetChatRoomView *)chatView{
    if (!_chatView) {
        _chatView = [[MeetChatRoomView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _chatView.delegate = self;
        _chatView.user_info = self.info;
    }
    return _chatView;
}



@end
