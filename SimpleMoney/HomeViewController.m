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


@interface HomeViewController() {
    MBProgressHUD *HUD;
}
@property (nonatomic, strong) NSDictionary *qrMerchant;
- (void)asyncLoadContacts;
@end

@implementation HomeViewController
@synthesize accountName;
@synthesize accountBalance;
@synthesize accountImage;
@synthesize ABContacts = _ABContacts;
@synthesize qrMerchant = _qrMerchant;

#pragma mark - View lifecycle
- (void)viewDidAppear:(BOOL)animated {
    [self asyncLoadContacts];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *dvc = segue.destinationViewController;
    
    //if we are going to send or request money views, we pass in the async-loaded contacts and set the page title and URL to post to
    if ([dvc isKindOfClass:[SendAndRequestMoneyTableViewController class]]) {
        SendAndRequestMoneyTableViewController *controller = (SendAndRequestMoneyTableViewController *)dvc;
        
        if (self.ABContacts) {
            controller.contacts = self.ABContacts;
        }
        
        NSString *resourcePath;
        NSString *sendButtonTitle;
        if ([segue.identifier isEqualToString:@"requestMoney"]) {
            resourcePath = @"/invoices";
            sendButtonTitle = @"Request Money";
        } else if ([segue.identifier isEqualToString:@"sendMoney"]) {
            resourcePath = @"/transactions";
            sendButtonTitle = @"Send Money";
        }
        controller.resourcePath =  resourcePath;
        [controller setSendButtonTitle:sendButtonTitle];
        
        //if we've authorized a transaction, we seed the view with the merchant name, image, and recommendation
    } else if ([dvc isKindOfClass:[PaymentAuthorizedViewController class]]) {
        PaymentAuthorizedViewController *controller = (PaymentAuthorizedViewController *)dvc;
        
        NSLog(@"Payment authorized");
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

#pragma mark - Sending RestKit requests
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
    } else {
        //TODO: error checking?
    }

}


#pragma mark - MBProgressHUDDelegate methods

- (void)HUDWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    hud = nil;
}

//not a delegate method, but this seems like a good place to put it
- (void)configureAndShowHUDWithLabelText:(NSString *)text {
    HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    HUD.delegate = self;
    [self.view.window addSubview:HUD];
    HUD.labelText = text;
    HUD.dimBackground = YES;
    [HUD show:YES];
}

- (void)hideHUDAfterShowingCompletionText:(NSString *)text withImageNamed:(NSString *)imageName afterDelay:(float)delay {
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = text;
    [HUD hide:YES afterDelay:delay];
}


@end
