//
//  MeetChatRoomView.m
//  meeting_iOS
//
//  Created by Fox Doggy on 2021/4/2.
//

#import "MeetChatRoomView.h"
#import "MeetingChatMessageCell.h"
#import "MeetingChatMessageTimeCell.h"
#import "MeetingMenuHeaderBarView.h"
#import "NSDate+Extend.h"
#import <YYKit/YYKit.h>

@interface MeetChatRoomView ()<UITableViewDelegate, UITableViewDataSource, MeetingChatInputViewDelegate,MeetingMenuHeaderBarViewDelegate>

@property (strong, nonatomic) UITableView *chatListView;
@property (strong, nonatomic) UIView *topLineView;
@property (strong, nonatomic) NSDate *lastMessageDate;
@property (strong, nonatomic) NSMutableArray<MeetingChatMessageDataModel *> *chatDataSource;

@end

static  NSString    *meetingChatMessageReuseId  =   @"kMeetingChatMessageCell";
static  NSString    *meetingChatMessageTimeReuseId  =   @"kMeetingChatMessageTimeCell";

@implementation MeetChatRoomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.chatDataSource = [NSMutableArray arrayWithCapacity:10];
        [self addSubview:self.topLineView];
        [self addSubview:self.chatListView];
        [self addSubview:self.inputView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _topLineView.frame = CGRectMake(0, kDNavBarAndStatusBarHeight, kScreenWidth, 0.5);
    _chatListView.frame = CGRectMake(0, kDNavBarAndStatusBarHeight + 0.5, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - kDNavBarAndStatusBarHeight - kBottomSafeH - 105.f);
    _inputView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - kBottomSafeH - 100.f, CGRectGetWidth(self.frame), 100.f + kBottomSafeH);
    [_chatListView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark - 添加聊天消息
- (void)addChatMessage:(MeetingChatMessageDataModel *)message_model {
    //添加聊天消息时，检测时间差是否大于5分钟，大于5分钟添加时间消息
    if (self.lastMessageDate == nil || [self.lastMessageDate intervalToDate:message_model.messageDate].minute > 5) {
        MeetingChatMessageDataModel *timeMessageModel = MeetingChatMessageDataModel.new;
        timeMessageModel.timeMessage = YES;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        timeMessageModel.nowTimeStr = [dateFormatter stringFromDate:message_model.messageDate];
        [self.chatDataSource addObject:timeMessageModel];
        self.lastMessageDate = message_model.messageDate;
    }
    [self.chatDataSource addObject:message_model];
 
    [self.chatListView reloadData];
    NSIndexPath *index = [NSIndexPath indexPathForRow:_chatDataSource.count - 1 inSection:0];
    [self.chatListView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeetingChatMessageDataModel *model = [_chatDataSource objectAtIndex:indexPath.row];
    if (model.timeMessage) {
        return 45;
    }
    return model.text_size.height + 50.f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeetingChatMessageDataModel *model = [_chatDataSource objectAtIndex:indexPath.row];
    if (model.timeMessage) {
        MeetingChatMessageTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:meetingChatMessageTimeReuseId forIndexPath:indexPath];
        [cell loadUIWithData:model];
        return cell;
    }
    MeetingChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:meetingChatMessageReuseId forIndexPath:indexPath];
    cell.is_self = [model.userId isEqualToString:@(self.user_info.user_ext_id).stringValue];
    [cell loadUIWithData:model];
    return cell;
}

#pragma mark - MeetingChatInputViewDelegate
- (void)meetingChatInputView:(MeetingChatInputView *)inputView DidFinishedEdit:(NSString *)text UserInfo:(RoomUserInfoModel *)userInfo {
    if (_delegate && [_delegate respondsToSelector:@selector(meetChatRoomView:DidUserInputText:userInfo:)]) {
        [_delegate meetChatRoomView:self DidUserInputText:text userInfo:userInfo];
    }
}

- (void)meetingChatInputViewChoseUserList:(MeetingChatInputView *)inputView{
    if (_delegate && [_delegate respondsToSelector:@selector(meetChatRoomViewChoseUserList:)]) {
        [_delegate meetChatRoomViewChoseUserList:self];
    }
}

- (void)meetingChatInputViewNeedClose:(MeetingChatInputView *)inputView {
    
}

- (void)meetingMenuHeaderNeedJumpToSetingPage {
    
}

- (void)meetingMenuHeaderNeedClose{
    if (self.delegatee && [self.delegatee respondsToSelector:@selector(meetingMenuBaseViewClose)]) {
        [self.delegatee meetingMenuBaseViewClose];
    }
}

#pragma mark - lazy load
- (UIView *)topLineView{
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
        _topLineView.backgroundColor = kLineColors;
    }
    return _topLineView;
}

- (UITableView *)chatListView {
    if (_chatListView == nil) {
        _chatListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 100 - kStatusBarH - kBottomSafeH) style:UITableViewStyleGrouped];
        _chatListView.backgroundColor = UIColor.whiteColor;
        _chatListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chatListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01f)];
        _chatListView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01f)];
        _chatListView.showsVerticalScrollIndicator = NO;
        _chatListView.delegate = self;
        _chatListView.dataSource = self;
        [_chatListView registerClass:MeetingChatMessageCell.class forCellReuseIdentifier:meetingChatMessageReuseId];
        [_chatListView registerClass:MeetingChatMessageTimeCell.class forCellReuseIdentifier:meetingChatMessageTimeReuseId];
    }
    return _chatListView;
}

- (MeetingChatInputView *)inputView {
    if (_inputView == nil) {
        _inputView = [[MeetingChatInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 100.f, CGRectGetWidth(self.frame), 100.f)];
        _inputView.delegate = self;
    }
    return _inputView;
}

@end
