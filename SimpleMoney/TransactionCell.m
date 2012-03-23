//
//  TransactionCell.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TransactionCell.h"

@implementation TransactionCell
@synthesize descriptionLabel;
@synthesize transactionID;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self showDescription:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)showDescription:(BOOL)shown {
    if (shown) {
        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationCurveEaseIn animations:^(void){
            self.dateLabel.alpha = 1.0;
            self.emailLabel.alpha = 1.0;
            if (self.payButton) self.payButton.alpha = 1.0;
        } completion:^(BOOL finished){}];
    } else {
        [UIView animateWithDuration:0.12 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
            self.dateLabel.alpha = 0.0;
            self.emailLabel.alpha = 0.0;
            if (self.payButton) self.payButton.alpha = 0.0;
        } completion:^(BOOL finished){}];
    }
}

- (IBAction)payButtonWasPressed:(id)sender {
    if ([self.superview isKindOfClass:[UITableView class]]) {
        UITableView *tv = (UITableView *)self.superview;
        BillsViewController *bvc = (BillsViewController *)tv.delegate;
        [bvc payBillButtonWasPressed:sender withTransactionID:transactionID];
    }
}

- (void)configureWithTransaction:(Transaction *)transaction isBill:(BOOL)bill {
    NSString *avatarURL = nil;
    if (bill) {
        self.nameLabel.text = transaction.recipient.name;
        self.emailLabel.text = transaction.recipient_email;
        self.descriptionLabel.text = transaction.transactionDescription;
        avatarURL = transaction.recipient.avatarURLsmall;
        if (self.payButton) self.transactionID = transaction.transactionID;
    } else {
        self.nameLabel.text = transaction.sender.name;
        self.emailLabel.text = transaction.sender_email;
        self.descriptionLabel.text = transaction.transactionDescription;
        avatarURL = transaction.sender.avatarURLsmall;
    }
    self.transactionAmountLabel.text = [NSString stringWithFormat:@"Amount: $%@",transaction.amount];
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:transaction.created_at dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    if ([avatarURL isEqualToString:@"/images/small/missing.png"]) {

    } else {
        [self.userImageView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"profile.png"]
        success:^(UIImage *image) {}
        failure:^(NSError *error) {}];
    }
    self.userImageView.layer.cornerRadius = 5.0;
    self.userImageView.layer.masksToBounds = YES;
}

@end
