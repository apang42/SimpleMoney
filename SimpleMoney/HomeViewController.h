//
//  HomeViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/Restkit.h>
#import "KeychainWrapper.h"
#import "User.h"
#import "Transaction.h"

@interface HomeViewController : UITableViewController <RKObjectLoaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *accountBalance;

- (IBAction)signOutButtonWasPressed:(id)sender;

@end
