//
//  SignUpViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"

@implementation SignUpViewController
@synthesize profileButton;

- (IBAction)profileImageWasPressed
{
    [self.view endEditing:YES];
    UIActionSheet *photoActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Photo", nil];
    
    [photoActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            break;
        default:
            break;
    }
}

- (IBAction)cancelButtonWasPressed
{
    [self dismissModalViewControllerAnimated:true];
}

- (IBAction)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landing-bg.png"]];
    [backgroundImage setFrame:self.tableView.frame];
    self.tableView.backgroundView = backgroundImage;
    
    [profileButton setImage:[UIImage imageNamed:@"profile-default.png"] borderWidth:5.0 shadowDepth:7.0 controlPointXOffset:30.0 controlPointYOffset:75.0 forState:UIControlStateNormal];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.profileButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
