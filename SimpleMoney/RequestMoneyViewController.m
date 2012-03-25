//
//  RequestMoneyViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RequestMoneyViewController.h"

#define kTABLEVIEWHEIGHT 150.0
@interface RequestMoneyViewController (PrivateMethods)
- (void)sendRequest;
- (void)showPeoplePicker;
- (void)selectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
- (NSMutableArray *)loadContactsFromAddressBook;
- (void)hideTableView;
- (void)showTableView;
@end

@implementation RequestMoneyViewController
@synthesize emailTextField;
@synthesize amountTextField;
@synthesize descriptionTextField;
@synthesize tableView = _tableView;

- (id)initWithCoder:(NSCoder *)decoder {
    if (![super initWithCoder:decoder]) return nil;
    // Load the user's contacts from their address book on another thread to improve performance
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0u);
    dispatch_async(queue, ^{
        contacts = [self loadContactsFromAddressBook];
        dispatch_sync(dispatch_get_main_queue(), ^{
            // When the contacts are loaded, set the filteredContacts instance variable and reload the tableView
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

- (IBAction)requestMoneyButtonWasPressed {
    loadingIndicator = [[MBProgressHUD alloc] initWithView:self.view.window];
    loadingIndicator.delegate = self;
    [self.view.window addSubview:loadingIndicator];
    loadingIndicator.dimBackground = YES;
    [loadingIndicator show:YES];
    
    [self dismissKeyboard];
    [self sendRequest];
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
    // Validate email with a regular expression
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    BOOL isValidEmail = [regExPredicate evaluateWithObject:emailTextField.text];
    
    // Make sure the user doesn't request money from themselves, they have a valid email address, and the amount they're trying to send is greater than 0
    if (([emailTextField.text isEqualToString:[KeychainWrapper load:@"userEmail"]]) || !isValidEmail || (!_amount || _amount <= 0)) {
        loadingIndicator.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
        loadingIndicator.mode = MBProgressHUDModeCustomView;
        if ([emailTextField.text isEqualToString:[KeychainWrapper load:@"userEmail"]]) {
            loadingIndicator.labelText = @"Can't request money from yourself.";
        } else if (!isValidEmail) {
            loadingIndicator.labelText = @"Invalid email address.";
        } else {
            loadingIndicator.labelText = @"Invalid amount.";
        }
        // Display the error message and hide it after 1 second
        [loadingIndicator hide:YES afterDelay:1.0];
    } else {
        // POST a new Transaction on the server
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
}

- (void)hideTableView {
    [UIView animateWithDuration:0.10 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
        float xPosition = self.tableView.frame.origin.x;
        float yPosition = self.tableView.frame.origin.y;
        float width = self.tableView.frame.size.width;
        self.tableView.frame = CGRectMake(xPosition, yPosition, width, 0.0);
        self.tableView.alpha = 0.0;
        
        self.amountTextField.alpha = 1.0;
        self.descriptionTextField.alpha = 1.0;
        self.requestMoneyButton.alpha = 1.0;
        
    } completion:^(BOOL finished){
        [self.tableView setHidden:YES];
    }];
}

- (void)showTableView {
    [self.tableView setHidden:NO];
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void){
        float xPosition = self.tableView.frame.origin.x;
        float yPosition = self.tableView.frame.origin.y;
        float width = self.tableView.frame.size.width;
        self.tableView.frame = CGRectMake(xPosition, yPosition, width, kTABLEVIEWHEIGHT);
        self.tableView.alpha = 1.0;
        
        self.amountTextField.alpha = 0.0;
        self.descriptionTextField.alpha = 0.0;
        self.requestMoneyButton.alpha = 0.0;
        
    } completion:^(BOOL finished){
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *selectedContact = [filteredContacts objectAtIndex:indexPath.row];
    NSLog(@"selectedContact: %@", selectedContact);
    self.emailTextField.text = [selectedContact objectForKey:@"email"];
    [self dismissKeyboard];
    if (!self.tableView.isHidden)[self hideTableView];
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
    if (textField == self.emailTextField) {
        // Filter the contacts by name and email
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[c] %@) || (email CONTAINS[c] %@)",textField.text,textField.text];
        NSMutableArray *copyOfContacts = [NSMutableArray arrayWithArray:contacts];
        NSArray *filtered  = [copyOfContacts filteredArrayUsingPredicate:predicate];
        filteredContacts = [NSMutableArray arrayWithArray:filtered];
        if (range.location == 0 ) {
            filteredContacts = copyOfContacts;
        }
        [self.tableView reloadData];
    } else if (textField == self.amountTextField) {
        // Clear all characters that are not numbers
        // (like currency symbols or dividers)
        NSString *cleanCentString = [[textField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        // Parse final integer value
        NSInteger centAmount = cleanCentString.integerValue;
        // Check the user input
        if (string.length > 0) {
            // Digit added
            centAmount = centAmount * 10 + string.integerValue;
        }
        else {
            // Digit deleted
            centAmount = centAmount / 10;
        }
        // Update call amount value
        _amount = [[NSNumber alloc] initWithFloat:(float)centAmount / 100.0f];
        // Write amount with currency symbols to the textfield
        NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_currencyFormatter setCurrencyCode:@"USD"];
        [_currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
        textField.text = [_currencyFormatter stringFromNumber:_amount];
        // Since we already wrote our changes to the textfield
        // we don't want to change the textfield again
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.emailTextField){
        if (self.tableView.isHidden)[self showTableView];
    }
    else {
        if (!self.tableView.isHidden)[self hideTableView];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    filteredContacts = contacts;
    [self.tableView reloadData];
    return YES;
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    hud = nil;
}

- (IBAction) newTransactionButtonWasPressed:(UIBarButtonItem *)sender {
    sender.enabled = NO;
    //Create a new UIView and set the background color to be a UIColor with pattern image of a screen capture
    UIView *imgView = [[UIView alloc] init];
    [self.view addSubview:imgView];
    _amount = 0;
    self.emailTextField.text = @"";
    self.amountTextField.text = @"";
    self.descriptionTextField.text = @"";
    [UIView transitionWithView:self.view duration:1 options:UIViewAnimationOptionTransitionCurlUp animations:^{}
                    completion:^(BOOL finished){
                        [imgView removeFromSuperview];
                        //Don't forget to re-enable the button at the completion block handler
                        sender.enabled = YES;
                    }];
}

- (void)request:(RKRequest *)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive {
    NSLog(@"RKRequest did receive data");
}

# pragma mark - RKObjectLoader Delegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);
    loadingIndicator.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
    loadingIndicator.mode = MBProgressHUDModeCustomView;
    loadingIndicator.labelText = @"Network error";
    [loadingIndicator hide:YES afterDelay:1];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    Transaction *t = object;
    NSLog(@"Transaction loaded: %@",t);
    // TODO: Display transaction information in success indicator
    loadingIndicator.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    loadingIndicator.mode = MBProgressHUDModeCustomView;
    loadingIndicator.labelText = @"Payment sent!";
    [loadingIndicator hide:YES afterDelay:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.layer.cornerRadius = 5.0;
    self.tableView.layer.masksToBounds = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end