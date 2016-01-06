//
//  MessagingOpponentMessageTableViewCell.h
//  MyMessenger
//
//  Created by SendBird Developers on 12/9/15.
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "MyUtils.h"

@interface MessagingOpponentMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameMessageContainerGap;

- (void)setMessage:(SendBirdMessage *)msg;
- (CGFloat) getCellHeight;

@end
