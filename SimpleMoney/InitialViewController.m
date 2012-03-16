//
//  InitialViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InitialViewController.h"

@implementation InitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *userEmail = [KeychainWrapper load:@"userEmail"];
    NSString *userPassword = [KeychainWrapper load:@"userPassword"];
    
    //[KeychainWrapper delete:@"userEmail"];
    //[KeychainWrapper delete:@"userPassword"];
    
    NSLog(@"keychain email: %@", userEmail);
    NSLog(@"keychain password: %@", userPassword);
    
    if (!userEmail || !userPassword) {
        [self performSegueWithIdentifier:@"authSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"homeSegue" sender:self];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
