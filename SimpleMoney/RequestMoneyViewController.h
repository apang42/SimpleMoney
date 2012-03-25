//
//  RequestMoneyViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Foundation/Foundation.h>
#import "KeychainWrapper.h"
#import "User.h"
#import "Transaction.h"
#import "MBProgressHUD.h"

@interface RequestMoneyViewController : UIViewController <UITextFieldDelegate, RKObjectLoaderDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *loadingIndicator;
    NSMutableArray *contacts;
    NSMutableArray *filteredContacts;
    NSNumber *_amount;
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *requestMoneyButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)newTransactionButtonWasPressed:(UIBarButtonItem *)sender;
- (IBAction)requestMoneyButtonWasPressed;
- (IBAction)dismissKeyboard;

@end
