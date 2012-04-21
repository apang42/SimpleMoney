//
//  PaymentAuthorizedViewController.m
//  fake
//
//  Created by Joshua Conner on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaymentAuthorizedViewController.h"
#import "User.h"

@interface PaymentAuthorizedViewController ()
@end

@implementation PaymentAuthorizedViewController
@synthesize AuthorizedBusinessView;
@synthesize AuthorizedBusinessImageView;
@synthesize AuthorizedBusinessTitleLabel;
@synthesize RecommendedBusinessView;
@synthesize RecommenderHintLabel;
@synthesize RecommendedBusinessTitleLabel;
@synthesize RecommendedBusinessAddressLabel;
@synthesize RecommendedBusinessDescriptionLabel;
@synthesize callPhoneButton;
@synthesize transaction = _transaction;


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    //configure display characteristics
    self.AuthorizedBusinessView.layer.cornerRadius = 5;
    self.RecommendedBusinessView.layer.cornerRadius = 5;
    [self.RecommendedBusinessDescriptionLabel sizeToFit];
    
    //set labels from transaction
    self.AuthorizedBusinessTitleLabel.text = self.transaction.recipient.name;
}

- (void)viewDidUnload
{
    [self setAuthorizedBusinessView:nil];
    [self setAuthorizedBusinessImageView:nil];
    [self setRecommenderHintLabel:nil];
    [self setRecommendedBusinessTitleLabel:nil];
    [self setAuthorizedBusinessTitleLabel:nil];
    [self setRecommendedBusinessAddressLabel:nil];
    [self setRecommendedBusinessDescriptionLabel:nil];
    [self setRecommendedBusinessView:nil];
    [self setCallPhoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController.navigationBar popNavigationItemAnimated:NO];
    }
    [super viewWillDisappear:animated];
}


#pragma mark - UI callbacks
- (IBAction)viewMapButtonPressed {
}

- (IBAction)callPhoneButtonPressed {
}
@end
