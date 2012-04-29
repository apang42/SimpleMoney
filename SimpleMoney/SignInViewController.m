//
//  SignInViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"
#import "HomeViewController.h"

@interface SignInViewController()
- (void)sendRequest;
@end

@implementation SignInViewController
@synthesize emailTextField;
@synthesize passwordTextField;


- (IBAction)cancelButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signUpButtonWasPressed {
    loadingIndicator = [[MBProgressHUD alloc] initWithView:self.tableView.window];
    loadingIndicator.delegate = self;
    [self.tableView.window addSubview:loadingIndicator];
    loadingIndicator.dimBackground = YES;
    [loadingIndicator show:YES];
    
    [self sendRequest];
    [self dismissKeyboard];
}

- (IBAction)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)sendRequest {
    NSLog(@"Sending request. Email: %@, PAssword: %@", self.emailTextField.text, self.passwordTextField.text);
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/users/sign_in" delegate:self block:^(RKObjectLoader* loader) {
        RKParams *params = [RKParams params];
        [params setValue:emailTextField.text forParam:@"user[email]"];
        [params setValue:passwordTextField.text forParam:@"user[password]"];
        loader.params = params;
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
        loader.method = RKRequestMethodPOST;
    }];
}


- (void) showHomeView {
    if ([[[[self.tabBarController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0] isKindOfClass:[HomeViewController class]]) {
        HomeViewController *hvc = (HomeViewController *)[[[self.tabBarController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
        [hvc setupAccountBalanceCell];
    }
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popViewControllerAnimated:NO];
}

# pragma mark - UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self signUpButtonWasPressed];
    }
    return YES;
}

# pragma mark - RKObjectLoader Delegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    User *user = object;
    NSLog(@"object loaded: %@", user);
    NSLog(@"object loaded: %@", user.userID);
    // Signed in successfully, let's add the user's credentials to the iOS keychain so we can sign them in automatically
    if (user.userID && ![user.userID isEqualToNumber:[NSNumber numberWithInt:0]]) {
        [KeychainWrapper save:@"userID" data:user.userID];
        [KeychainWrapper save:@"userEmail" data:user.email];
        [KeychainWrapper save:@"userBalance" data:user.balance];
        [KeychainWrapper save:@"userAvatarSmall" data:user.avatarURLsmall];
        [KeychainWrapper save:@"userPassword" data:self.passwordTextField.text];
        
        loadingIndicator.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
        loadingIndicator.mode = MBProgressHUDModeCustomView;
        loadingIndicator.labelText = @"Signed in!";
        [loadingIndicator hide:YES afterDelay:1];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC), dispatch_get_current_queue(), ^{
           [self showHomeView];
        });
        
    } else {
        loadingIndicator.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
        loadingIndicator.labelText = @"Invalid username or password.";
        loadingIndicator.mode = MBProgressHUDModeCustomView;
        [loadingIndicator hide:YES afterDelay:1];
    }
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landing-bg.png"]];
    [backgroundImage setFrame:self.tableView.frame];
    self.tableView.backgroundView = backgroundImage;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.emailTextField becomeFirstResponder];
}


@end
