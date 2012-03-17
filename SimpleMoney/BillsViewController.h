//
//  UnpaidTransactionsViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "PullToRefreshView.h"
#import "Transaction.h"
#import "User.h"
@interface BillsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, RKObjectLoaderDelegate, PullToRefreshViewDelegate> {
    PullToRefreshView *pull;
    NSArray *pendingTransactions;
}

@end
