//
//  InvoicesViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InvoicesViewController.h"
#import <Foundation/Foundation.h>

@interface InvoicesViewController (PrivateMethods)
- (void)loadData;
- (void)reloadTableData;
- (UIView *)unpaidHeaderView;
- (UIView *)paidHeaderView;
- (void)sortTransactionsFromUser:(User *)user;
@end

@implementation InvoicesViewController
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
    label.text = @"Unpaid Invoices";
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
    label.text = @"Paid Invoices";
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor colorWithWhite:0.13 alpha:1];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 2.0);
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:18.0];
    
    [paidHeaderView addSubview:label];
    
    return paidHeaderView;
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
    
    unpaidInvoicesArray = [[NSMutableArray alloc] initWithCapacity:1];
    paidInvoicesArray = [[NSMutableArray alloc] initWithCapacity:1];
    
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
        if ([unpaidInvoicesArray count] > 0) {
            return [unpaidInvoicesArray count];
        }
    } else {
        if ([paidInvoicesArray count] > 0) {
            return [paidInvoicesArray count];
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
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invoiceCell"];
    
    // If there is no reusable cell of this type, create a new one
    if (!cell) {
        cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"invoiceCell"];
    }

        
    if (indexPath.section == 0) {

        // Unpaid Invoices
        if ([unpaidInvoicesArray count] > 0) {
                       
            Transaction *transaction = [unpaidInvoicesArray objectAtIndex:indexPath.row];
            [cell configureWithTransaction:transaction isBill:NO isSelected:(indexPath == self.selectedRowIndex)];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
            cell.textLabel.text = @"You have no unpaid invoices";
        }
    }
    else {
        // Paid Invoices
        if ([paidInvoicesArray count] > 0) {
            Transaction *transaction = [paidInvoicesArray objectAtIndex:indexPath.row];
            [cell configureWithTransaction:transaction isBill:NO isSelected:(indexPath == self.selectedRowIndex)];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
            cell.textLabel.text = @"You have no paid invoices";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set the selected cell's height to 130, deslected cells are 85
    // Empty cell placeholders are 40
    switch (indexPath.section) {
        case 0:
            if (!unpaidInvoicesArray || !unpaidInvoicesArray.count) return 40;
            break;
            
        default:
            if (!paidInvoicesArray || !paidInvoicesArray.count) return 40;
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
    NSLog(@"transactions: %@", transactions);
    
    [paidInvoicesArray removeAllObjects];
    [unpaidInvoicesArray removeAllObjects];
    for (id transaction in transactions) {
        Transaction *t = transaction;
        if ([t.recipient_email isEqualToString:[KeychainWrapper load:@"userEmail"]]) {
            if ([t.complete boolValue]) {
                [paidInvoicesArray addObject:t];
            } else {
                [unpaidInvoicesArray addObject:t];
            }
        }
    }
}

#pragma mark RKObjectLoaderDelegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    User *user = object;
    // Update KeyChain with most recent data.
    [KeychainWrapper save:@"userEmail" data:user.email];
    [KeychainWrapper save:@"userBalance" data:user.balance];
    [KeychainWrapper save:@"userAvatarSmall" data:user.avatarURLsmall];
    [self sortTransactionsFromUser:user];
    [self.tableView reloadData];
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
