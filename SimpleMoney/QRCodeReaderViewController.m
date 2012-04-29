//
//  QRCodeReaderViewController.m
//  SimpleMoney
//
//  Created by Joshua Conner on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QRCodeReaderViewController.h"
#import "PaymentAuthorizedViewController.h"
#import "Transaction.h"
#import "Merchant.h"
#import "User.h"

#define kPINCONSTANT @"1111"

@interface QRCodeReaderViewController () {
    CGRect iPhoneSource;
    CGRect iPhoneDestination;
    NSTimer *animationTimer;
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) NSDictionary *qrMerchant;
@property (strong, nonatomic) Transaction *transaction;
@property (strong, nonatomic) Merchant *recommendation;
@property (strong, nonatomic) User *recipient;
@end

@implementation QRCodeReaderViewController
@synthesize iphoneImage;
@synthesize greenSquare;
@synthesize readerView;
@synthesize qrMerchant = _qrMerchant;
@synthesize transaction = _transaction;
@synthesize recommendation = _recommendation;
@synthesize recipient = _recipient;

- (void) cleanup
{
    cameraSim = nil;
    readerView.readerDelegate = nil;
    readerView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    iPhoneDestination = iPhoneSource = self.iphoneImage.frame;
    iPhoneDestination.origin.x -= 225;
    
    /*
     * Set up the ZBar reader
     */
    readerView.readerDelegate = self;
    
    //ZBar can scan lots of different bar-code type stuff, but we're only interested in QR codes
    [readerView.scanner setSymbology: 0
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [readerView.scanner setSymbology: ZBAR_QRCODE
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    
}

- (void)viewDidUnload
{
    [self cleanup];
    [animationTimer invalidate];
    animationTimer = nil;
    [self setIphoneImage:nil];
    [self setGreenSquare:nil];
    [self setReaderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)viewDidAppear:(BOOL)animated {
    // run the reader when the view is visible
    [readerView start];
    
    //start animation
    [self animateiPhoneIcon];
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(animateiPhoneIcon)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [readerView stop];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *dvc = segue.destinationViewController;
    
    //if we're having the user enter their PIN, we pass the Merchant Name
    if ([dvc isKindOfClass:[GCStoryboardPINViewController class]]) {
        GCStoryboardPINViewController *controller = (GCStoryboardPINViewController *)dvc;
        [controller configureWithMode:GCPINViewControllerModeVerify delegate:self];
        controller.messageText = @"Enter your PIN to authorize payment a to:";
        controller.businessNameText = [self.qrMerchant objectForKey:@"name"];
        
        //TODO: unset this hint from the demo!
        controller.errorText = [NSString stringWithFormat:@"Invalid PIN. (Hint: %@)", kPINCONSTANT];
        
    //if they've successfully paid, we pass the transaction info an recommendation to 
    //the PaymentAuthorizedVC
    } else if ([dvc isKindOfClass:[PaymentAuthorizedViewController class]]) {
        PaymentAuthorizedViewController *controller = (PaymentAuthorizedViewController *)dvc;
        controller.transaction = self.transaction;
        controller.recommendation = self.recommendation;
        controller.recipient = self.recipient;
    }
}

#pragma mark - Animation
- (void)animateiPhoneIcon {

    [UIView animateWithDuration:1.0
                          delay:0.5
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.iphoneImage.frame = iPhoneDestination;
                     } 
                     completion:^(BOOL finished){
                         self.greenSquare.alpha = 0.6;
                         [self resetAnimation];
                     }];

}

- (void)resetAnimation {
    [UIView animateWithDuration:0.2
                          delay:1.5
                        options:UIViewAnimationOptionCurveEaseOut 
                     animations:^{
                         self.greenSquare.alpha = 0.0;
                         self.iphoneImage.alpha = 0.0;
                          }
                     completion:^(BOOL finished){
                         self.iphoneImage.frame = iPhoneSource;
                         [UIView animateWithDuration:0.4
                                               delay:0.6
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.iphoneImage.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished){
                                              //nothing
                                          }];
                     }];
}

#pragma mark - ZBarReaderViewDelegate
- (void) readerView: (ZBarReaderView*) view
     didReadSymbols: (ZBarSymbolSet*) syms
          fromImage: (UIImage*) img
{
    //stop the "how to use qr" animation
    [animationTimer invalidate];

    ZBarSymbol *symbol = nil;
    // Grab the first result
    for(symbol in syms)
        break;
    
    // Encode the QRCode with JSON
    // ex: {"email":"walmart@walmart.com", "name":"Walmart"}
    
    // Convert the decoded string to a NSData object, then convert the data to a dictionary
    NSData *symbolData = [symbol.data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonParsingError = nil;
    self.qrMerchant = [NSJSONSerialization JSONObjectWithData:symbolData options:0 error:&jsonParsingError];
    NSLog(@"qrCodeData: %@", self.qrMerchant);
    NSLog(@"error: %@",jsonParsingError);
    
    // If there isn't a parsing error, POST a new incomplete transaction
    if (!jsonParsingError) {
        [self performSegueWithIdentifier:@"enterPinSegue" sender:self];
    } else {
        //TODO: handle JSON parsing error
    }
}

#pragma mark- RestKit requests
- (void) sendAuthorization {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/transactionWithRecommendation" delegate:self block:^(RKObjectLoader* loader) {
        RKParams *params = [RKParams params];
        [params setValue:[self.qrMerchant objectForKey:@"email"] forParam:@"transaction[recipient_email]"];
        [params setValue:@"false" forParam:@"transaction[complete]"];
        loader.params = params;
//        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[Transaction class]];
        loader.method = RKRequestMethodPOST;
    }];
}


# pragma mark - RKObjectLoaderDelegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);
    // TODO: Display error message via HUD
    [self hideHUDAfterShowingCompletionText:@"Error" detailsText:@"Please try again" imageNamed:@"x.png" afterDelay:1.5];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    NSLog(@"recieved objects: %@", objects);
    
    id object;
    for (object in objects) {
        // Check the object type
        if ([object isKindOfClass:[Transaction class]]) {
            // This occurs after scanning a QRCode encoded with JSON
            self.transaction = object;
            NSLog(@"posted a new transaction: %@", object);
            
            if (self.recommendation && self.recipient) {
                [self transactionFinished];
            }
            
        } else if ([object isKindOfClass:[Merchant class]]) {
            NSLog(@"recommendation: %@", object);
            self.recommendation = object;
            
            if (self.transaction && self.recipient) {
                [self transactionFinished];
            }
            
        } else if ([object isKindOfClass:[User class]]) {
            self.recipient = object;
            NSLog(@"Recipient recieved! %@", self.recipient);
            
            [self transactionFinished];
        }
    }
}

- (void)transactionFinished {
    [self hideHUDAfterShowingCompletionText:@"Paid!" detailsText:nil imageNamed:@"checkmark" afterDelay:1.0];
    
    [self performSegueWithIdentifier:@"paidSegue" sender:self];
}
#pragma mark - GCStoryboardPinViewControllerDelegate methods
- (void) pinViewController:(GCStoryboardPINViewController *)controller didEnterPIN:(NSString *)PIN; {
    NSLog(@"Did enter pin: %@", PIN);
    
    if ([PIN isEqualToString:kPINCONSTANT]) {
        [self dismissModalViewControllerAnimated:YES];
        
        [self configureAndShowHUDWithLabelText:@"Sending"];
        [self sendAuthorization];
        
    } else {
        [controller wrong];
    }
}

- (void) pinViewController:(GCStoryboardPINViewController *)controller didCancel:(BOOL)cancel; {
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:NO];
}


#pragma mark - MBProgressHUDDelegate methods
- (void)HUDWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidden
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

-(void)hideHUDAfterShowingCompletionText:(NSString *)text detailsText:(NSString *)detailsText imageNamed:(NSString *)imageName afterDelay:(float)delay {
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = text;
    HUD.detailsLabelText = detailsText;
    [HUD hide:YES afterDelay:delay];
}

@end
