//
//  TransactionCell.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Transaction.h"
#import "UIImage+ScaledImage.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Curled.h"
#import "BillsViewController.h"

@interface TransactionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) NSNumber *transactionID;

- (IBAction)payButtonWasPressed:(id)sender;
- (void)configureWithTransaction:(Transaction *)transaction isBill:(BOOL)bill isSelected:(BOOL)selected;
- (void)showDescription:(BOOL)shown;
- (void)setLoading:(BOOL)loading;
@end
