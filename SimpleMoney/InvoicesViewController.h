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
#import "KeychainWrapper.h"
#import "Transaction.h"
#import "User.h"
#import "UIImage+ScaledImage.h"
#import "UIImageView+WebCache.h"
#import "TransactionCell.h"

@interface InvoicesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, RKObjectLoaderDelegate, PullToRefreshViewDelegate> {
    PullToRefreshView *pull;
    NSMutableArray *unpaidInvoicesArray;
    NSMutableArray *paidInvoicesArray;
}

@property (weak, nonatomic) NSIndexPath *selectedRowIndex;

@end