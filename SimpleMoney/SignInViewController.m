//
//  SignInViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"

@implementation SignInViewController
@synthesize emailTextField;
@synthesize passwordTextField;

- (IBAction)cancelButtonWasPressed {
    [self dismissModalViewControllerAnimated:true];
}

- (IBAction)signUpButtonWasPressed {
    [self dismissKeyboard];
    [self sendRequest];
}

- (IBAction)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)sendRequest {
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
    // Signed in successfully, let's add the user's credentials to the iOS keychain so we can sign them in automatically
    if ([user.email isEqualToString:self.emailTextField.text]) {
        NSLog(@"Attempting to save user %@", user.email);

        [KeychainWrapper save:@"userID" data:user.userID];
        [KeychainWrapper save:@"userEmail" data:user.email];
        [KeychainWrapper save:@"userPassword" data:self.passwordTextField.text];
    }
    NSLog(@"about to perform segue");
    [self performSegueWithIdentifier:@"signInSegue" sender:self];
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
