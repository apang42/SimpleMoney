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
- (void)deselectAllCells;
@end

@implementation BillsViewController
@synthesize selectedRowIndex;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [self reloadTableData];
}

- (void)reloadTableData {
    [self deselectAllCells];
    [self loadData];
    [pull finishedLoading];
}

- (void)loadData {
    // Load the object model via RestKit	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"/users/%@", [KeychainWrapper load:@"userID"]] delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self deselectAllCells];

    unpaidBillsArray = [[NSMutableArray alloc] initWithCapacity:1];
    paidBillsArray = [[NSMutableArray alloc] initWithCapacity:1];
    [self loadData];
    pull = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    pull.delegate = self;
    [self.tableView addSubview:pull];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
            [cell configureWithTransaction:transaction];
        } else {
            cell.transactionAmountLabel.text = @"You have no unpaid bills";
        }
    }
    else {
        // Paid bills
        if ([paidBillsArray count] > 0) {
            Transaction *transaction = [paidBillsArray objectAtIndex:indexPath.row];
            [cell configureWithTransaction:transaction];
        } else {
            cell.transactionAmountLabel.text = @"You have no paid bills";
        }
    }
    //[cell showDescription:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedRowIndex && ([self.selectedRowIndex compare:indexPath] == NSOrderedSame)) {
        return 130;
    } else {
        return 85;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)deselectAllCells {
    for (int i = 0; i < [unpaidBillsArray count]; i++) {
        TransactionCell *cell = (TransactionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSLog(@"cell: %@", cell);
        [cell showDescription:NO];
    }
    for (int i = 0; i < [paidBillsArray count]; i++) {
        TransactionCell *cell = (TransactionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        NSLog(@"cell: %@", cell);
        [cell showDescription:NO];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectAllCells];
    self.selectedRowIndex = indexPath;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    TransactionCell *selectedCell = (TransactionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [selectedCell showDescription:YES];
}

#pragma mark RKObjectLoaderDelegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    User *user = object;
    
    [paidBillsArray removeAllObjects];
    [unpaidBillsArray removeAllObjects];
    for (id transaction in user.transactions) {
        Transaction *t = transaction;
        if ([t.sender_email isEqualToString:user.email]) {
            if ([t.complete boolValue]) {
                [paidBillsArray addObject:t];
            } else {
                [unpaidBillsArray addObject:t];
            }
        }
    }
    //NSLog(@"unpaid bills: %@", unpaidBillsArray);
    //NSLog(@"paid bills: %@", paidBillsArray);
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	NSLog(@"R error: %@", error);
}

- (void)requestDidStartLoad:(RKRequest *)request{
    NSLog(@"R did start load");
}

- (void)requestDidCancelLoad:(RKRequest *)request{
    NSLog(@"R did cancel load");
}

- (void)requestDidTimeout:(RKRequest *)request{
    NSLog(@"R did timeout");
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    RKLogError(@"Load of RKRequest %@ failed with error: %@", request, error);
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    RKLogCritical(@"Loading of RKRequest %@ completed with status code %d. Response body: %@", request, response.statusCode, [response bodyAsString]);    
}

- (void)request:(RKRequest *)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive {

}


@end
