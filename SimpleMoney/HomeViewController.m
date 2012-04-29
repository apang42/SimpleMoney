//
//  HomeViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "SendAndRequestMoneyTableViewController.h"
#import "GCStoryboardPINViewController.h"
#import "PaymentAuthorizedViewController.h"
#import "AuthViewController.h"
#import "Merchant.h"
#import "LocalDealsTabBarViewController.h"

@interface HomeViewController() {
    CLLocationManager *locationManager;
    MBProgressHUD *HUD;
    BOOL didLogin;
    BOOL didSignOut;
}
@property (nonatomic, strong) NSDictionary *qrMerchant;
@property (nonatomic, strong) NSArray *nearbyMerchants;
@property (nonatomic, strong) CLLocation *currentLocation;

- (void)asyncLoadContacts;
@end

@implementation HomeViewController
@synthesize accountName;
@synthesize accountBalance;
@synthesize accountImage;
@synthesize ABContacts = _ABContacts;
@synthesize qrMerchant = _qrMerchant;
@synthesize nearbyMerchants = _nearbyMerchants;
@synthesize currentLocation = _currentLocation;

#pragma mark - View lifecycle
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self asyncLoadContacts];
}

- (void) viewWillAppear:(BOOL)animated {
    [self setupAccountBalanceCell];
    if (![KeychainWrapper load:@"userEmail"] || ![KeychainWrapper load:@"userPassword"]) {
        [self.tabBarController setSelectedIndex:1];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    //hiding the tabBar leaves a black space where it used to be, so we also resize the main view's frame
    self.tabBarController.tabBar.hidden = YES;
    [[self.tabBarController.view.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, 320, 480)];
    
    self.accountImage.layer.cornerRadius = 5.0;
    self.accountImage.layer.masksToBounds = YES;
    
    NSString *userEmail = [KeychainWrapper load:@"userEmail"];
    NSString *userPassword = [KeychainWrapper load:@"userPassword"];
    
    NSLog(@"keychain email: %@", userEmail);
    NSLog(@"keychain password: %@", userPassword);

    if (userEmail && userPassword) {
        didLogin = YES;
        
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [objectManager loadObjectsAtResourcePath:@"/users/sign_in" delegate:self block:^(RKObjectLoader* loader) {
            RKParams *params = [RKParams params];
            [params setValue:userEmail forParam:@"user[email]"];
            [params setValue:userPassword forParam:@"user[password]"];
            loader.params = params;
            loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
            loader.method = RKRequestMethodPOST;
        }];
    }
}

- (void) viewDidUnload {
    [self setAccountName: nil];
    [self setAccountBalance: nil];
    [self setAccountImage:nil];
    [self setABContacts:nil];
    [self setQrMerchant:nil];
    HUD.delegate = nil;
    [HUD removeFromSuperview];
    HUD = nil;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *dvc = segue.destinationViewController;
    
    //if we are going to send or request money views, we pass in the async-loaded contacts and set the page title and URL to post to
    if ([dvc isKindOfClass:[SendAndRequestMoneyTableViewController class]]) {
        SendAndRequestMoneyTableViewController *controller = (SendAndRequestMoneyTableViewController *)dvc;
        
        if (self.ABContacts) {
            controller.contacts = self.ABContacts;
        }
        
        //we set its isRequestMoney property to true if it's a requestMoney
        if ([segue.identifier isEqualToString:@"requestMoney"]) {
            controller.isRequestMoney = YES;
        }
    } else if ([dvc isKindOfClass:[LocalDealsTabBarViewController class]]) {
        LocalDealsTabBarViewController *controller = (LocalDealsTabBarViewController *)dvc;
        controller.nearbyMerchants = self.nearbyMerchants;
        controller.currentLocation = self.currentLocation;
    }
}


- (void)setupAccountBalanceCell {
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

/**
 * Asynchronously loads contacts to pass to the send or request money views if we segue to them.
 */
- (void)asyncLoadContacts {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0u);
    dispatch_async(queue, ^{
        self.ABContacts = [[NSMutableArray alloc] init];
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex n = ABAddressBookGetPersonCount(addressBook);
        for(int i = 0; i < n; i++) {
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
            NSString *name = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonLastNameProperty);
            NSArray *emails;
            NSData *imageData;
            
            if (lastName) {
                name = [name stringByAppendingFormat: @" %@", lastName];
            } 
            
            ABMultiValueRef emailAddresses = ABRecordCopyValue(ref, kABPersonEmailProperty);
            
            int count = ABMultiValueGetCount(emailAddresses);
            
            if (name && count > 0) {
                emails = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(emailAddresses);
                
                if (ABPersonHasImageData(ref)) {
                    imageData = (__bridge_transfer NSData*)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
                    
                    
                    [self.ABContacts addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"name", emails, @"emails", imageData, @"imageData", nil]];
                    
                } else {
                    [self.ABContacts addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:name,@"name",emails,@"emails", nil]];
                }
            }
            NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            [self.ABContacts sortUsingDescriptors:[NSArray arrayWithObject:sortByName]];
        }
    });
}

- (void) loadNearbyMerchants {
    //HACK: couldn't get GET parameters to pass correctly for this call, so I'm encoding them directly into the URL because UGRADS in in 6 hours
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *resourcePath = [NSString stringWithFormat:@"/near/%f/%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self block:^(RKObjectLoader* loader) {
        
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[Merchant class]];
        
        loader.method = RKRequestMethodGET;
    }];

}

- (void) deleteUserData {
    // Delete the user's data from the keychain.
    [KeychainWrapper delete:@"userID"];
    [KeychainWrapper delete:@"userEmail"];
    [KeychainWrapper delete:@"userBalance"];
    [KeychainWrapper delete:@"userAvatarSmall"];
    [KeychainWrapper delete:@"userPassword"];
}


// Sends a DELETE request to /users/sign_out
- (IBAction)signOutButtonWasPressed:(id)sender {
    didSignOut = YES;
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/users/sign_out" delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
        loader.method = RKRequestMethodDELETE;
    }];
    [self deleteUserData];
    

    [self configureAndShowHUDWithLabelText:@"Signing out..." detailsText:nil imageNamed:nil];
    [self hideHUDAfterShowingCompletionText:@"Signing out..." withImageNamed:nil afterDelay:1.0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [self showAuthView];
    });
}

- (void)showAuthView {
    [self.tabBarController setSelectedIndex:1];

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

        //if userID exists, then login was not successful
        if (user.userID && ![user.userID isEqualToNumber:[NSNumber numberWithInt:0]]) {
            NSLog(@"user.userID exists: %@", user.userID);
            self.accountName.text = user.email;
            NSNumber *userBalance = user.balance;
            NSNumber *formattedBalance = [[NSNumber alloc] initWithFloat:[userBalance floatValue] / 100.0f];
            self.accountBalance.text = [currencyFormatter stringFromNumber:formattedBalance];
            
            //cache user data to keychain
            [KeychainWrapper save:@"userID" data:user.userID];
            [KeychainWrapper save:@"userEmail" data:user.email];
            [KeychainWrapper save:@"userBalance" data:user.balance];
            [KeychainWrapper save:@"userAvatarSmall" data:user.avatarURLsmall];
            
        //if no user id, then bad login => redirect to auth
        //this also happens on signout, so we check didSignOut before we do anything
        } else if (!didSignOut) {
            [self deleteUserData];
            [self configureAndShowHUDWithLabelText:@"Login expired." detailsText:@"Please sign in again." imageNamed:@"x.png"];
            [HUD hide:YES afterDelay:1.0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                [self showAuthView];
            });
            
        }
    }
}

//Since the nearbyMerchants call returns a list of objects we can use didLoadObjectS to get them all
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    NSLog(@"loaded nearby merchants: %@", objects);
    self.nearbyMerchants = objects;
}

#pragma mark - MBProgressHUDDelegate methods

- (void)HUDWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    hud = nil;
}

//not a delegate method, but this seems like a good place to put it
- (void)configureAndShowHUDWithLabelText:(NSString *)text detailsText:(NSString*)detailsText imageNamed:(NSString *)imageName {
    HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    HUD.delegate = self;
    [self.view.window addSubview:HUD];
    HUD.labelText = text;
    HUD.detailsLabelText = detailsText;
    
    if (imageName) {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        HUD.mode = MBProgressHUDModeCustomView;
    }
                 
    HUD.dimBackground = YES;
    [HUD show:YES];
}

- (void)hideHUDAfterShowingCompletionText:(NSString *)text withImageNamed:(NSString *)imageName afterDelay:(float)delay {
    if (imageName) {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        HUD.mode = MBProgressHUDModeCustomView;
    }
    HUD.labelText = text;
    [HUD hide:YES afterDelay:delay];
}


#pragma mark - AuthControllerDelegate methods 
//When the user successfully signs in, fill in the screen with the appropriate info
- (void)authViewController:(AuthViewController *)controller didSignIn:(BOOL)success; {
    if (success) {
        didLogin = YES;
        [self setupAccountBalanceCell];
        [self dismissModalViewControllerAnimated:YES];
    }
}


#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if(newLocation.horizontalAccuracy <= 500.0f) { 
        [locationManager stopUpdatingLocation];
        NSLog(@"LOCATION: %@", newLocation);
        self.currentLocation = newLocation;
        [self loadNearbyMerchants];
    }
}

//stop trying to update location is user denies location updating
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        [locationManager stopUpdatingLocation];
    }
}

@end
