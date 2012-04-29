//
//  PaymentAuthorizedViewController.m
//  fake
//
//  Created by Joshua Conner on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaymentAuthorizedViewController.h"
#import "User.h"
#import "UIImageView+WebCache.h"

@interface PaymentAuthorizedViewController () {
    UIImage *placeholdImage;
    NSNumberFormatter *numberFormatter;
}
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
@synthesize RecommendedBusinessImageView;
@synthesize transaction = _transaction;
@synthesize recipient = _recipient;
@synthesize recommendation = _recommendation;


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    placeholdImage = [UIImage imageNamed:@"profile.png"];
    numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.positiveFormat = @"0.##";

    //configure display characteristics
    self.AuthorizedBusinessView.layer.cornerRadius = 5;
    self.RecommendedBusinessView.layer.cornerRadius = 5;
    
    //set labels from transaction
    self.AuthorizedBusinessTitleLabel.text = self.transaction.recipient.name;
    [self.AuthorizedBusinessImageView setImageWithURL:[NSURL URLWithString:self.recipient.avatarURLsmall] placeholderImage:placeholdImage];
    
    //set labels from recommendation
    self.RecommendedBusinessTitleLabel.text = self.recommendation.name;
    self.RecommendedBusinessAddressLabel.text = [NSString stringWithFormat:@"%@ (1.2 mi. away)", self.recommendation.address];
    self.RecommendedBusinessDescriptionLabel.text = self.recommendation.details;
    [self.RecommendedBusinessImageView setImageWithURL:[NSURL URLWithString:self.recommendation.avatarURLsmall] placeholderImage:placeholdImage];
    
    self.RecommenderHintLabel.text = [NSString stringWithFormat:@"SimpleMoney users who shop at %@ also enjoy:", self.recipient.name];
    
    [self.RecommendedBusinessDescriptionLabel sizeToFit];
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
    [self setRecommendedBusinessImageView:nil];
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
        
        NSString *address = [@"http://maps.google.com/maps?saddr=Current Location&daddr=%@" stringByAppendingString:self.recommendation.address];
        
        NSString *urlString = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
