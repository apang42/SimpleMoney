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
#import "GCStoryboardPINViewController.h"

@interface BillsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, RKObjectLoaderDelegate, PullToRefreshViewDelegate, GCStoryboardPINViewControllerDelegate> {
    PullToRefreshView *pull;
    NSMutableArray *unpaidBillsArray;
    NSMutableArray *paidBillsArray;
    UIView *unpaidHeaderView;
    UIView *paidHeaderView;
}

@property (strong, nonatomic) NSIndexPath *selectedRowIndex;

- (void)payBillButtonWasPressed:(id)sender withTransactionID:(NSNumber *)transactionID;

@end