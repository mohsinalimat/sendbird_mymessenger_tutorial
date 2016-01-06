//
//  MessagingViewController.m
//  MyMessenger
//
//  Created by SendBird Developers on 12/5/15.
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessagingViewController.h"
#import "MessagingSystemMessageTableViewCell.h"
#import "MessagingBroadcastMessageTableViewCell.h"
#import "MessagingMessageTableViewCell.h"
#import "MessagingOpponentMessageTableViewCell.h"
#import "MessagingFileLinkTableViewCell.h"
#import "MessageOpponentFileLinkTableViewCell.h"

@interface MessagingViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate> {
    SendBirdMessagingChannel *currentChannel;
    NSMutableArray *messages;
    BOOL isLoadingMessage;
    BOOL firstTimeLoading;
    BOOL openImagePicker;
    long long lastMessageTimestamp;
    long long firstMessageTimestamp;
    NSMutableDictionary *typeStatus;
    NSMutableDictionary *readStatus;
    BOOL scrollLocked;
    NSTimer *typingIndicatorTimer;
}

@end

@implementation MessagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    isLoadingMessage = NO;
    firstTimeLoading = YES;
    lastMessageTimestamp = LLONG_MIN;
    firstMessageTimestamp = LLONG_MAX;
    scrollLocked = NO;
    
    messages = [[NSMutableArray alloc] init];
    
    [self.sendFileButton.layer setBorderColor:[[UIColor blueColor] CGColor]];
    [self.sendMessageButton.layer setBorderColor:[[UIColor blueColor] CGColor]];
    [self.messageTextField.layer setBorderColor:[[UIColor blueColor] CGColor]];
    
    [self.messagingTableView setDelegate:self];
    [self.messagingTableView setDataSource:self];
    [self.messagingTableView setSeparatorColor:[UIColor clearColor]];
    [self.messagingTableView setContentInset:UIEdgeInsetsMake(0, 0, 12, 0)];
    
    [self.prevMessageLoadingIndicator setHidden:YES];
    
    [self hideTyping];
    
    [self.messageTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.messageTextField setDelegate:self];
    
    [self.navigationBarTitle setTitle:[MyUtils generateMessagingTitle:currentChannel]];
    
    // See 'How to build an iOS messaging app'
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startTimer
{
    // See 'How to build an iOS messaging app'
}

- (void)clearTypingIndicator:(NSTimer *)timer
{
    // See 'How to build an iOS messaging app'
}

- (void)setMessagingChannel:(SendBirdMessagingChannel *)ch
{
    currentChannel = ch;
}

- (IBAction)closeMessaging:(id)sender {
    [SendBird disconnect];
    [[self delegate] prepareCloseMessagingViewController];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)leaveMessaging:(id)sender {
    [SendBird endMessagingWithChannelUrl:[currentChannel getUrl]];
    [SendBird disconnect];
    [[self delegate] prepareCloseMessagingViewController];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardWillShow:(NSNotification*)notif
{
    NSDictionary *keyboardInfo = [notif userInfo];
    NSValue *keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    [self.inputViewBottomMargin setConstant:keyboardFrameEndRect.size.height];
    [self.view updateConstraints];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottomWithReloading:NO animated:NO];
    });
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [self.inputViewBottomMargin setConstant:0];
    [self.view updateConstraints];
    [self scrollToBottomWithReloading:NO animated:NO];
}

- (void)scrollToBottomWithReloading:(BOOL)reload animated:(BOOL)animated
{
    if (reload) {
        [self.messagingTableView reloadData];
    }
    
    if (scrollLocked) {
        return;
    }
    
    unsigned long msgCount = [messages count];
    if (msgCount > 0) {
        [self.messagingTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(msgCount - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void) loadPreviousMessages {
    // See 'How to build an iOS messaging app'
}

- (IBAction)clickSendFileButton:(id)sender {
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    mediaUI.mediaTypes = mediaTypes;
    [mediaUI setDelegate:self];
    openImagePicker = YES;
    [self presentViewController:mediaUI animated:YES completion:nil];
}

- (void) sendMessage
{
    NSString *message = [self.messageTextField text];
    if ([message length] > 0) {
        [self.messageTextField setText:@""];
        [SendBird sendMessage:message];
        [SendBird typeEnd];
    }
    scrollLocked = NO;
}

- (IBAction)clickSendMessageButton:(id)sender {
    [self sendMessage];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMessage];
    
    return YES;
}

- (void) textFieldDidChange:(UITextView *)textView
{
    // See 'How to build an iOS messaging app'
}

- (void) setTypeStatus:(NSString *)userId andTimestamp:(long long)ts
{
    if ([userId isEqualToString:[SendBird getUserId]]) {
        return;
    }
    
    if (typeStatus == nil) {
        typeStatus = [[NSMutableDictionary alloc] init];
    }
    
    if(ts <= 0) {
        [typeStatus removeObjectForKey:userId];
    } else {
        [typeStatus setObject:[NSNumber numberWithLongLong:ts] forKey:userId];
    }
}

- (void) showTyping
{
    // See 'How to build an iOS messaging app'
}

- (void) hideTyping
{
    [self.typingIndicatorView setHidden:YES];
    [self.typeStatusLabel setHidden:YES];
    self.typingIndicatorHeight.constant = 0;
    [self.view updateConstraints];
}

- (void) setReadStatus:(NSString *)userId andTimestamp:(long long)ts
{
    // See 'How to build an iOS messaging app'
}

- (void) updateMessagingChannel:(SendBirdMessagingChannel *)channel
{
    // See 'How to build an iOS messaging app'
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[MessagingMembersInChannelViewController class]]) {
        MessagingMembersInChannelViewController *vc = (MessagingMembersInChannelViewController *)segue.destinationViewController;
        [vc setSendBirdMessagingChannel:currentChannel];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell *commonCell = nil;
        SendBirdMessageModel *msgModel = (SendBirdMessageModel *)[messages objectAtIndex:[indexPath row]];
        
        if ([msgModel isKindOfClass:[SendBirdMessage class]]) {
            SendBirdMessage *msg = (SendBirdMessage *)msgModel;
            if ([[[msg sender] guestId] isEqualToString:[SendBird getUserId]]) {
                MessagingMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingMessageCell"];
                [cell setReadStatus:readStatus];
                [cell setMessage:(SendBirdMessage *)msgModel];
                commonCell = cell;
            }
            else {
                MessagingOpponentMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingOpponentMessageCell"];
                [cell setMessage:(SendBirdMessage *)msgModel];
                commonCell = cell;
            }
        }
        else if ([msgModel isKindOfClass:[SendBirdBroadcastMessage class]]) {
            MessagingBroadcastMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingBroadcastMessageCell"];
            [cell setBroadcastMessage:(SendBirdBroadcastMessage *)msgModel];
            commonCell = cell;
        }
        else if ([msgModel isKindOfClass:[SendBirdSystemMessage class]]) {
            MessagingSystemMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingSystemMessageCell"];
            [cell setSystemMessage:(SendBirdSystemMessage *)msgModel];
            commonCell = cell;
        }
        else if ([msgModel isKindOfClass:[SendBirdFileLink class]]) {
            SendBirdFileLink *msg = (SendBirdFileLink *)msgModel;
            if ([[[msg sender] guestId] isEqualToString:[SendBird getUserId]]) {
                MessagingFileLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingFileLinkCell"];
                [cell setReadStatus:readStatus];
                [cell setFileMessage:(SendBirdFileLink *)msgModel];
                commonCell = cell;
            }
            else {
                MessageOpponentFileLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingOpponentFileLinkCell"];
                [cell setFileMessage:(SendBirdFileLink *)msgModel];
                commonCell = cell;
            }
        }
        
        if ([indexPath row] == 0) {
            [self loadPreviousMessages];
        }
        
        if ([indexPath row] == [messages count] - 1) {
            scrollLocked = NO;
        }
        
        [commonCell setNeedsLayout];
        
        return commonCell;
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

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [messages count] - 1) {
        scrollLocked = YES;
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollLocked  = YES;
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        CGFloat height = 0;
        SendBirdMessageModel *msgModel = (SendBirdMessageModel *)[messages objectAtIndex:[indexPath row]];
        
        if ([msgModel isKindOfClass:[SendBirdMessage class]]) {
            SendBirdMessage *msg = (SendBirdMessage *)msgModel;
            if ([[[msg sender] guestId] isEqualToString:[SendBird getUserId]]) {
                MessagingMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingMessageCell"];
                [cell setMessage:(SendBirdMessage *)msgModel];
                 height = [cell getCellHeight];
            }
            else {
                MessagingOpponentMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingOpponentMessageCell"];
                [cell setMessage:(SendBirdMessage *)msgModel];
                 height = [cell getCellHeight];
            }
        }
        else if ([msgModel isKindOfClass:[SendBirdBroadcastMessage class]]) {
            MessagingBroadcastMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingBroadcastMessageCell"];
            [cell setBroadcastMessage:(SendBirdBroadcastMessage *)msgModel];
            height = [cell getCellHeight];
        }
        else if ([msgModel isKindOfClass:[SendBirdSystemMessage class]]) {
            MessagingSystemMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingSystemMessageCell"];
            [cell setSystemMessage:(SendBirdSystemMessage *)msgModel];
            height = [cell getCellHeight];
        }
        else if ([msgModel isKindOfClass:[SendBirdFileLink class]]) {
            SendBirdFileLink *msg = (SendBirdFileLink *)msgModel;
            if ([[[msg sender] guestId] isEqualToString:[SendBird getUserId]]) {
                MessagingFileLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingFileLinkCell"];
                [cell setFileMessage:(SendBirdFileLink *)msgModel];
                height = [cell getCellHeight];
            }
            else {
                MessageOpponentFileLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagingOpponentFileLinkCell"];
                [cell setFileMessage:(SendBirdFileLink *)msgModel];
                height = [cell getCellHeight];
            }
        }

        return height;;
    }
    else {
        return 64;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // See 'How to build an iOS messaging app'
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        openImagePicker = NO;
    }];
}

@end
