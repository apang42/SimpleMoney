//
//  SendMoneyViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendMoneyViewController.h"

@interface SendMoneyViewController (PrivateMethods)
- (void)sendRequest;
@end

@implementation SendMoneyViewController
@synthesize emailTextField;
@synthesize amountTextField;
@synthesize descriptionTextField;

- (IBAction)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)sendMoneyButtonWasPressed {
    [self sendRequest];
}

- (void)sendRequest {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/transactions" delegate:self block:^(RKObjectLoader* loader) {
        RKParams *params = [RKParams params];
        [params setValue:emailTextField.text forParam:@"transaction[recipient_email]"];
        [params setValue:amountTextField.text forParam:@"transaction[amount]"];
        [params setValue:descriptionTextField.text forParam:@"transaction[description]"];
        [params setValue:@"true" forParam:@"transaction[complete]"];
        loader.params = params;
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
        loader.method = RKRequestMethodPOST;
    }];
}

# pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.amountTextField becomeFirstResponder];
    } else {
        [self dismissKeyboard];
    }
    return YES;
}

# pragma mark - RKObjectLoader Delegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    Transaction *t = object;
    NSLog(@"Transaction loaded: %@",t);
    /*User *user = object;
    // Signed in successfully, let's add the user's credentials to the iOS keychain so we can sign them in automatically
    if ([user.email isEqualToString:self.emailTextField.text]) {
        NSLog(@"Attempting to save user %@", user.email);
        
        [KeychainWrapper save:@"userID" data:user.userID];
        [KeychainWrapper save:@"userEmail" data:user.email];
        [KeychainWrapper save:@"userPassword" data:self.passwordTextField.text];
    }
    NSLog(@"about to perform segue");
    [self performSegueWithIdentifier:@"signInSegue" sender:self];*/
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
