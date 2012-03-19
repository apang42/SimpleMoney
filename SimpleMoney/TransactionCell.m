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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)showDescription:(BOOL)shown {
    if (shown) {
        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationCurveEaseIn animations:^(void){
            self.dateLabel.alpha = 1.0;
            self.emailLabel.alpha = 1.0;
        } completion:^(BOOL finished){}];

    } else {
        [UIView animateWithDuration:0.12 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
            self.dateLabel.alpha = 0.0;
            self.emailLabel.alpha = 0.0;
        } completion:^(BOOL finished){}];
    }
}

- (void)configureWithTransaction:(Transaction *)transaction {
    self.nameLabel.text = transaction.recipient.name;
    self.emailLabel.text = transaction.recipient.email;
    self.descriptionLabel.text = transaction.transactionDescription;
    self.transactionAmountLabel.text = [NSString stringWithFormat:@"Amount: $%@",transaction.amount];
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:transaction.created_at dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    
    NSString *avatarURL = transaction.recipient.avatarURLsmall;
    if ([avatarURL isEqualToString:@"/images/small/missing.png"]) {

    } else {
        [self.userImageView setImageWithURL:[NSURL URLWithString:transaction.recipient.avatarURLsmall] placeholderImage:[UIImage imageNamed:@"profile.png"]
        success:^(UIImage *image) {
            NSLog(@"Success!");
        }
        failure:^(NSError *error) {
            NSLog(@"Failure!");
        }];
    }
    self.userImageView.layer.cornerRadius = 5.0;
    self.userImageView.layer.masksToBounds = YES;
}

@end
