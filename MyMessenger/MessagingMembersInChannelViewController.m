//
//  MessagingMembersInChannelViewController.m
//  MyMessenger
//
//  Created by SendBird Developers on 12/11/15.
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessagingMembersInChannelViewController.h"

@interface MessagingMembersInChannelViewController ()<UITableViewDataSource, UITableViewDelegate> {
    SendBirdMessagingChannel *currentChannel;
    NSMutableArray *userArray;
    BOOL isLoadingUser;
    SendBirdMemberListQuery *memberListQuery;
}

@end

@implementation MessagingMembersInChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    userArray = [[NSMutableArray alloc] init];
    [self.messagingMemberTableView setDataSource:self];
    [self.messagingMemberTableView setDelegate:self];
    [self.messagingMemberTableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    [SendBird loginWithUserId:[SendBird deviceUniqueID] andUserName:[MyUtils getUserName] andUserImageUrl:[MyUtils getUserProfileImage] andAccessToken:@""];
    memberListQuery = [SendBird queryMemberListInChannel:[currentChannel getUrl]];
    [memberListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
        for (SendBirdMemberInMessagingChannel *user in queryResult) {
            [userArray addObject:user];
        }
        [self.messagingMemberTableView reloadData];
    } endBlock:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSendBirdMessagingChannel:(SendBirdMessagingChannel *)channel
{
    currentChannel = channel;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadNextMemberList
{
    if (![memberListQuery hasNext]) {
        return;
    }
    
    if (isLoadingUser) {
        return;
    }
    isLoadingUser = YES;
    
    [memberListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
        for (SendBirdMember *member in queryResult) {
            [userArray addObject:member];
        }
        [self.messagingMemberTableView reloadData];
        isLoadingUser = NO;
    } endBlock:^(NSError *error) {
        
    }];
}

- (IBAction)closeMembers:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        MessagingMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingMemberrCell"];
        SendBirdMemberInMessagingChannel *member = (SendBirdMemberInMessagingChannel *)[userArray objectAtIndex:[indexPath row]];
        [cell setSendBirdMember:member];
        
        if ([indexPath row] + 1 == [userArray count]) {
            [self loadNextMemberList];
        }
        
        return cell;
    }
    else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

@end
