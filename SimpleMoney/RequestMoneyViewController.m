//
//  RequestMoneyViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RequestMoneyViewController.h"

@interface RequestMoneyViewController (PrivateMethods)
- (void)sendRequest;
- (void)showPeoplePicker;
- (void)selectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
@end

@implementation RequestMoneyViewController
@synthesize emailTextField;
@synthesize amountTextField;
@synthesize descriptionTextField;

- (IBAction)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)requestMoneyButtonWasPressed {
    [self sendRequest];
}

- (IBAction)addContactButtonWasPressed {
    [self showPeoplePicker];
}

- (void)showPeoplePicker {
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentModalViewController:picker animated:YES];
}

- (void)selectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    NSString *email = nil;
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person, property);
    if (ABMultiValueGetCount(emailAddresses) > 0 && property ==  kABPersonEmailProperty) {
        email = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emailAddresses, identifier);
        NSLog(@"email : %@", email);
        emailTextField.text = email;
    } else {
        email = @"no email address";
    }
}

- (void)sendRequest {
    if ([emailTextField.text isEqualToString:[KeychainWrapper load:@"userEmail"]]) {
        // You shouldn't be able to request money from yourself.
    }
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/invoices" delegate:self block:^(RKObjectLoader* loader) {
        RKParams *params = [RKParams params];
        [params setValue:emailTextField.text forParam:@"transaction[sender_email]"];
        [params setValue:amountTextField.text forParam:@"transaction[amount]"];
        [params setValue:descriptionTextField.text forParam:@"transaction[description]"];
        [params setValue:@"false" forParam:@"transaction[complete]"];
        loader.params = params;
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
        loader.method = RKRequestMethodPOST;
    }];
}

# pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.amountTextField becomeFirstResponder];
    } else if (textField == self.amountTextField) {
        [self.descriptionTextField becomeFirstResponder];
    } else {
        [self dismissKeyboard];
    }
    return YES;
}

# pragma mark - ABPeoplePickerNavigationController delegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    // What should we do once we select a user?
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    [self selectPerson:person property:property identifier:identifier];
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}

# pragma mark - RKObjectLoader Delegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    Transaction *t = object;
    NSLog(@"Transaction loaded: %@",t);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [emailTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [amountTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [descriptionTextField setBorderStyle:UITextBorderStyleRoundedRect];
    
    [amountTextField setKeyboardType:UIKeyboardTypeDecimalPad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
