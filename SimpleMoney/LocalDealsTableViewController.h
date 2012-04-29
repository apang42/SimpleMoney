//
//  LocalDealsTableViewController.h
//  SimpleMoney
//
//  Created by Joshua Conner on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Merchant.h"

@interface LocalDealsTableViewController : UITableViewController
@property (strong, nonatomic) NSArray *nearbyMerchants;
@end
