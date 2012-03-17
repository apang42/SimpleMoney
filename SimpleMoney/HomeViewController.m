//
//  HomeViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "Transaction.h"

@interface HomeViewController (PrivateMethods)
- (void)signOut;
@end

@implementation HomeViewController
@synthesize accountName;
@synthesize accountBalance;

// Sends a DELETE request to /users/sign_out
- (IBAction)signOutButtonWasPressed:(id)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/users/sign_out" delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
        loader.method = RKRequestMethodDELETE;
    }];
    [self performSegueWithIdentifier:@"loggedOutSegue" sender:self];
}

- (void)selectPerson:(ABRecordRef)person {
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty);

    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonLastNameProperty);
    
    NSString *email = nil;
    email = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonEmailProperty);
    if (email) {
        // Set email to be sender_email or receiver_id
        // Perform some segue
    } else {
        // Invite person to SimpleMoney
        // Perform some segue
    }
    
    NSLog(@"Selected: %@ %@ %@",firstName, lastName, email);
}

- (void)showPeoplePicker {
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentModalViewController:picker animated:YES];
}

# pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select row: %@", indexPath);

    if (indexPath.section == 0) {
        NSLog(@"Account");
    } else {
        switch (indexPath.row) {
            case 0:
                NSLog(@"QuickPay");
                break;
            case 1:
                NSLog(@"SendMoney");
                [self showPeoplePicker];
                break;
            case 2:
                NSLog(@"RequestMoney");
                [self showPeoplePicker];
                break;
            default:
                break;
        }
    }
}

# pragma mark - ABPeoplePickerNavigationController delegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    // What should we do once we select a user?
    [self selectPerson:person];
    [self dismissModalViewControllerAnimated:YES];
    return NO;    
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

# pragma mark - RKObjectLoader Delegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    User *user = object;
    NSLog(@"loaded user with transaction count: %u", user.transactions.count);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    // TODO: remove this code!
    /*NSLog(@"loaded objects: %@", objects);
    NSFetchRequest *userRequest = [User fetchRequest];
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"email = %@",[KeychainWrapper load:@"userEmail"]];
    [userRequest setPredicate:userPredicate];
    User *currentUser = [User objectWithFetchRequest:userRequest];
    
    NSLog(@"current user: %@", currentUser);
    for (id t in currentUser.transactions) {
        Transaction *transaction = t;
        NSLog(@"Transaction: %@", transaction.transactionDescription);
    }
    
    NSLog(@"user transactions: %@", currentUser.transactions);*/
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.hidesBackButton = YES;
    
    self.accountName.text = [KeychainWrapper load:@"userEmail"];
    self.accountBalance.text = [KeychainWrapper load:@"userEmail"];

    // TODO: remove this code!
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"/users/%@", [KeychainWrapper load:@"userID"]] delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
