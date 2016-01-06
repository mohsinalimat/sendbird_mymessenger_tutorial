//
//  MessagingMessageTableViewCell.h
//  MyMessenger
//
//  Created by SendBird Developers on 12/6/15.
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "MyUtils.h"

@interface MessagingMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerLeftPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerBottomPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerTopPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerRightPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameMessageContainerGap;

@property (retain) NSMutableDictionary *readStatus;

- (void)setMessage:(SendBirdMessage *)msg;
- (CGFloat) getCellHeight;

@end
