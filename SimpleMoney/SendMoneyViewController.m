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
- (void)showPeoplePicker;
- (void)selectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
- (NSMutableArray *)loadContactsFromAddressBook;
@end

@implementation SendMoneyViewController
@synthesize emailTextField;
@synthesize amountTextField;
@synthesize descriptionTextField;
@synthesize tableView = _tableView;

- (id)initWithCoder:(NSCoder *)decoder {
    if (![super initWithCoder:decoder]) return nil;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0u);
    dispatch_async(queue, ^{
        contacts = [self loadContactsFromAddressBook];
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"done fetching contacts, %@", contacts);
            filteredContacts = contacts;
            [self.tableView reloadData];
        });
    });
    return self;
}

- (IBAction)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)sendMoneyButtonWasPressed {
    [self dismissKeyboard];
    [self sendRequest];
    loadingIndicator = [[MBProgressHUD alloc] initWithView:self.view];
    loadingIndicator.delegate = self;
    [self.view addSubview:loadingIndicator];
    loadingIndicator.dimBackground = YES;
    [loadingIndicator show:YES];
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

- (NSMutableArray *)loadContactsFromAddressBook {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    for(int i = 0; i < n; i++) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        NSString *firstName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSString *name;
        NSString *email;
        if (lastName) {
            name = [firstName stringByAppendingFormat: @" %@", lastName];
        } else {
            name = firstName;
        }
        ABMultiValueRef emailAddresses = ABRecordCopyValue(ref, kABPersonEmailProperty);
        int count = ABMultiValueGetCount(emailAddresses);
        if (count > 0 && name) {
            email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emailAddresses, 0);
            [results addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:name,@"name",email,@"email",nil]];
        }
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [results sortUsingDescriptors:[NSArray arrayWithObject:sortByName]];
    }
    return results;
}

- (void)sendRequest {
    if ([emailTextField.text isEqualToString:[KeychainWrapper load:@"userEmail"]]) {
        // TODO: Display error - Can't send money to yourself.
    }
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

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Check for a reusable cell first, use that if it exists
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    // If there is no reusable cell of this type, create a new one
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"billCell"];
    }
    NSMutableDictionary *contact = [filteredContacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [contact objectForKey:@"name"];
    cell.detailTextLabel.text = [contact objectForKey:@"email"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [filteredContacts count];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[c] %@) || (email CONTAINS[c] %@)",textField.text,textField.text ];
    NSMutableArray *copyOfContacts = [NSMutableArray arrayWithArray:contacts];
    NSArray *filtered  = [copyOfContacts filteredArrayUsingPredicate:predicate];
    filteredContacts = [NSMutableArray arrayWithArray:filtered];
    if (filteredContacts.count > 0 ) [self.tableView reloadData];
    return YES;
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    hud = nil;
}

# pragma mark - ABPeoplePickerNavigationController delegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
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
    loadingIndicator.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
    loadingIndicator.mode = MBProgressHUDModeCustomView;
    [loadingIndicator hide:YES afterDelay:1];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    Transaction *t = object;
    NSLog(@"Transaction loaded: %@",t);
    // TODO: Display transaction information in success indicator
    loadingIndicator.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    loadingIndicator.mode = MBProgressHUDModeCustomView;
    [loadingIndicator hide:YES afterDelay:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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