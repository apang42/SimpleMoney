//
//  InvoicesViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BillsViewController.h"
#import <Foundation/Foundation.h>

@interface BillsViewController (PrivateMethods)
- (void)loadData;
- (void)reloadTableData;
- (UIView *)unpaidHeaderView;
- (UIView *)paidHeaderView;
- (void)sortTransactionsFromUser:(User *)user;
@end

@implementation BillsViewController
@synthesize selectedRowIndex;

- (UIView *)unpaidHeaderView {
    if (unpaidHeaderView) return unpaidHeaderView;
    
    float w = [[UIScreen mainScreen] bounds].size.width;
    CGRect headerFrame = CGRectMake(0.0, 0.0, w, 40.0);
    unpaidHeaderView = [[UIView alloc] initWithFrame:headerFrame];
    unpaidHeaderView.backgroundColor = [UIColor clearColor];
    
    CGRect labelFrame = CGRectMake(20.0, 8.0, w-8.0, 20.0);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Unpaid Bills";
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor colorWithWhite:0.13 alpha:1];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 2.0);
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:18.0];
    
    [unpaidHeaderView addSubview:label];    
    return unpaidHeaderView;
}

- (UIView *)paidHeaderView {
    if (paidHeaderView) return paidHeaderView;
    
    float w = [[UIScreen mainScreen] bounds].size.width;
    CGRect headerFrame = CGRectMake(0.0, 0.0, w, 40.0);
    paidHeaderView = [[UIView alloc] initWithFrame:headerFrame];
    paidHeaderView.backgroundColor = [UIColor clearColor];
    
    CGRect labelFrame = CGRectMake(20.0, 8.0, w-8.0, 20.0);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Paid Bills";
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor colorWithWhite:0.13 alpha:1];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 2.0);
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:18.0];
    
    [paidHeaderView addSubview:label];
    return paidHeaderView;
}

- (void)payBillButtonWasPressed:(id)sender withTransactionID:(NSNumber *)transactionID {
    NSLog(@"payBillButtonWasPressed withTransactionID: %@", transactionID);
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"/transactions/%@", transactionID] delegate:self block:^(RKObjectLoader* loader) {
        RKParams *params = [RKParams params];
        [params setValue:@"true" forParam:@"transaction[complete]"];
        loader.params = params;
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[Transaction class]];
        loader.method = RKRequestMethodPUT;
    }];
}

# pragma mark - PullToRefreshViewDelegate methods

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [self reloadTableData];
}

- (void)reloadTableData {
    [self loadData];
    [pull finishedLoading];
}

- (void)loadData {
    // Fetch the current user from the server
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"/users/%@", [KeychainWrapper load:@"userID"]] delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Resize the tableView cells
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    
    unpaidBillsArray = [[NSMutableArray alloc] initWithCapacity:1];
    paidBillsArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Grab the current user from the DB and sort the transaction data.
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"email == %@", [KeychainWrapper load:@"userEmail"]];
    User *user = [User objectWithPredicate:userPredicate];
    [self sortTransactionsFromUser:user];

    // If the user.transactions is nil or empty, load data from the server
    if (!user.transactions || !user.transactions.count) [self loadData];

    pull = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    pull.delegate = self;
    [self.tableView addSubview:pull];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 ) {
        if ([unpaidBillsArray count] > 0) {
            return [unpaidBillsArray count];
        }
    } else {
        if ([paidBillsArray count] > 0) {
            return [paidBillsArray count];
        }
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) return [self unpaidHeaderView];
    else return [self paidHeaderView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Check for a reusable cell first, use that if it exists
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"billCell"];
    
    // If there is no reusable cell of this type, create a new one
    if (!cell) {
        cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"billCell"];
    }
    
    if (indexPath.section == 0) {
        // Unpaid bills
        if ([unpaidBillsArray count] > 0) {
            Transaction *transaction = [unpaidBillsArray objectAtIndex:indexPath.row];
            [cell configureWithTransaction:transaction isBill:YES];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
            cell.textLabel.text = @"You have no unpaid bills";
        }
    }
    else {
        // Paid bills
        if ([paidBillsArray count] > 0) {
            Transaction *transaction = [paidBillsArray objectAtIndex:indexPath.row];
            [cell configureWithTransaction:transaction isBill:YES];
            cell.payButton = nil;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
            cell.textLabel.text = @"You have no paid bills";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set the selected cell's height to 130, deslected cells are 85
    // Empty cell placeholders are 40
    switch (indexPath.section) {
        case 0:
            if (!unpaidBillsArray || !unpaidBillsArray.count) return 40;
            break;
        default:
            if (!paidBillsArray || !paidBillsArray.count) return 40;
            break;
    }
    if (self.selectedRowIndex && ([self.selectedRowIndex compare:indexPath] == NSOrderedSame)) {
        return 130;
    } else {
        return 85;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRowIndex = indexPath;
    // Animate cell size change
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)sortTransactionsFromUser:(User *)user {
    // Create a sort descriptor to sort user.transactions by the created_at property, in descending order.
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObjects:descriptor, nil];
    NSArray *transactions = [[user.transactions allObjects] sortedArrayUsingDescriptors:descriptors];
    NSLog(@"sortTransactionsFromUser: transactions:%@", transactions);

    // Get ready for some fresh data...
    [paidBillsArray removeAllObjects];
    [unpaidBillsArray removeAllObjects];
    for (id transaction in transactions) {
        Transaction *t = transaction;
        if ([t.sender_email isEqualToString:[KeychainWrapper load:@"userEmail"]]) {
            if ([t.complete boolValue]) {
                [paidBillsArray addObject:t];
            } else {
                [unpaidBillsArray addObject:t];
            }
        }
    }
}

#pragma mark RKObjectLoaderDelegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    if ([object isKindOfClass:[User class]]) {
        User *user = object;
        // Update KeyChain with most recent data.
        [KeychainWrapper save:@"userEmail" data:user.email];
        [KeychainWrapper save:@"userBalance" data:user.balance];
        [KeychainWrapper save:@"userAvatarSmall" data:user.avatarURLsmall];
        [self sortTransactionsFromUser:user];
        [self.tableView reloadData];
    } else if([object isKindOfClass:[Transaction class]]) {
        Transaction *transaction = object;
        NSLog(@"objectLoader:didLoadObject: transaction %@", transaction);
        [self loadData];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	NSLog(@"R error: %@", error);
    // TODO: Display Error message for failed bills fetch
}

- (void)requestDidTimeout:(RKRequest *)request{
    NSLog(@"R did timeout");
    // TODO: Display Error message for server timeout / check internet connection
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    RKLogCritical(@"Loading of RKRequest %@ completed with status code %d. Response body: %@", request, response.statusCode, [response bodyAsString]);
}

@end
