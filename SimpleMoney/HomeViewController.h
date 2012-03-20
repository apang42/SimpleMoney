//
//  HomeViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/Restkit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "KeychainWrapper.h"
#import "User.h"
#import "Transaction.h"

@interface HomeViewController : UITableViewController <RKObjectLoaderDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *accountBalance;

- (IBAction)signOutButtonWasPressed:(id)sender;
- (void)selectPerson:(ABRecordRef)person;
- (void)showPeoplePicker;

@end
