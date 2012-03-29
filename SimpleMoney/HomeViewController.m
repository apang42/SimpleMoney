//
//  HomeViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController (PrivateMethods)
- (void)signOut;
@end

@implementation HomeViewController
@synthesize accountName;
@synthesize accountBalance;

- (id)initWithCoder:(NSCoder *)decoder {
    if (![super initWithCoder:decoder]) return nil;

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Fetch fresh user data from the server.
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"/users/%@", [KeychainWrapper load:@"userID"]] delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.accountImage.layer.cornerRadius = 5.0;
    self.accountImage.layer.masksToBounds = YES;
    
    currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setCurrencyCode:@"USD"];
    [currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
    
    NSNumber *userBalance = [KeychainWrapper load:@"userBalance"];
    NSNumber *formattedBalance = [[NSNumber alloc] initWithFloat:[userBalance floatValue] / 100.0f];
    self.accountBalance.text = [currencyFormatter stringFromNumber:formattedBalance];
    
    self.accountName.text = [KeychainWrapper load:@"userEmail"];
    NSString *avatarURL = [KeychainWrapper load:@"userAvatarSmall"];
    
    if (![avatarURL isEqualToString:@"/images/small/missing.png"]) {
        [self.accountImage setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"profile.png"]
                                   success:^(UIImage *image) {}
                                   failure:^(NSError *error) {}];
    }
}

// Sends a DELETE request to /users/sign_out
- (IBAction)signOutButtonWasPressed:(id)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/users/sign_out" delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
        loader.method = RKRequestMethodDELETE;
    }];
    [self performSegueWithIdentifier:@"loggedOutSegue" sender:self];
    
    // Delete the user's data from the keychain.
    [KeychainWrapper delete:@"userID"];
    [KeychainWrapper delete:@"userEmail"];
    [KeychainWrapper delete:@"userBalance"];
    [KeychainWrapper delete:@"userAvatarSmall"];
    [KeychainWrapper delete:@"userPassword"];
}



# pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // If QuickPay was selected...
    if ((indexPath.section == 1) && (indexPath.row == 0)) {
        // Push ZBar controller
        // ADD: present a barcode reader that scans from the camera feed
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        reader.supportedOrientationsMask = ZBarOrientationMaskAll;
        
        ZBarImageScanner *scanner = reader.scanner;
        // TODO: (optional) additional reader configuration here
        
        // EXAMPLE: disable rarely used I2/5 to improve performance
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
        // present and release the controller
        [self presentModalViewController:reader animated: YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info {
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    // Grab the first result
    for(symbol in results)
        break;

    // Encode the QRCode with JSON
    // ex: {"merchant_email":"walmart@walmart.com"}
    
    // Convert the decoded string to a NSData object, then convert the data to a dictionary
    NSData *symbolData = [symbol.data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonParsingError = nil;
    NSDictionary *qrCodeData = [NSJSONSerialization JSONObjectWithData:symbolData options:0 error:&jsonParsingError];
    NSLog(@"qrCodeData: %@", qrCodeData);
    NSLog(@"error: %@",jsonParsingError);
    
    // If there isn't a parsing error, POST a new incomplete transaction
    if (!jsonParsingError) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [objectManager loadObjectsAtResourcePath:@"/transactions" delegate:self block:^(RKObjectLoader* loader) {
            RKParams *params = [RKParams params];
            [params setValue:[qrCodeData objectForKey:@"merchant_email"] forParam:@"transaction[recipient_email]"];
            [params setValue:@"false" forParam:@"transaction[complete]"];
            loader.params = params;
            loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[Transaction class]];
            loader.method = RKRequestMethodPOST;
        }];
    }
    [reader dismissModalViewControllerAnimated: YES];
}


# pragma mark - RKObjectLoaderDelegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);
    // TODO: Display error message via HUD
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    // Check the object type
    if ([object isKindOfClass:[User class]]) {
        User *user = object;
        self.accountName.text = user.email;
        NSNumber *userBalance = [KeychainWrapper load:@"userBalance"];
        NSNumber *formattedBalance = [[NSNumber alloc] initWithFloat:[userBalance floatValue] / 100.0f];
        self.accountBalance.text = [currencyFormatter stringFromNumber:formattedBalance];
    } else if ([object isKindOfClass:[Transaction class]]) {
        // This occurs after scanning a QRCode encoded with JSON
        Transaction *t = object;
        NSLog(@"posted a new transaction: %@", t);
    }

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
