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
- (void)loadObjectsFromDataStoreWithUser:(User *)user;
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

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [self reloadTableData];
}

- (void)reloadTableData {
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    unpaidBillsArray = [[NSMutableArray alloc] initWithCapacity:1];
    paidBillsArray = [[NSMutableArray alloc] initWithCapacity:1];
    [self loadData];
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
            [cell configureWithTransaction:transaction];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
            cell.textLabel.text = @"You have no unpaid bills";
        }
    }
    else {
        // Paid bills
        if ([paidBillsArray count] > 0) {
            Transaction *transaction = [paidBillsArray objectAtIndex:indexPath.row];
            [cell configureWithTransaction:transaction];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
            cell.textLabel.text = @"You have no paid bills";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRowIndex = indexPath;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)loadObjectsFromDataStoreWithUser:(User *)user {
    NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"];
    NSFetchRequest* request = [Transaction fetchRequest];
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(sender_email == %@ OR recipient_email == %@) AND user == %@", userEmail,userEmail,user];
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    [request setPredicate:predicate];
    NSArray *transactions = [Transaction objectsWithFetchRequest:request];
    
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
    User *user = object;
    NSLog(@"user from objL: %@", user);
    [[NSUserDefaults standardUserDefaults] setObject:user.email forKey:@"userEmail"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [self loadObjectsFromDataStoreWithUser: user];
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
