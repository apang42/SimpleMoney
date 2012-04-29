//
//  PaymentAuthorizedViewController.h
//  fake
//
//  Created by Joshua Conner on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h> //for border radius setting
#import "Transaction.h"
#import "Merchant.h"
#import "User.h"

@interface PaymentAuthorizedViewController : UIViewController
//UI
@property (weak, nonatomic) IBOutlet UIView *AuthorizedBusinessView;
@property (weak, nonatomic) IBOutlet UIImageView *AuthorizedBusinessImageView;
@property (weak, nonatomic) IBOutlet UILabel *AuthorizedBusinessTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *RecommendedBusinessView;
@property (weak, nonatomic) IBOutlet UILabel *RecommenderHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *RecommendedBusinessTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *RecommendedBusinessAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *RecommendedBusinessDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *RecommendedBusinessImageView;

//Non-UI
@property (strong, nonatomic) Transaction *transaction;
@property (strong, nonatomic) Merchant *recommendation;
@property (strong, nonatomic) User *recipient;


- (IBAction)viewMapButtonPressed;
@end
