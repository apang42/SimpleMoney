//
//  HomeViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/Restkit.h>
#import "KeychainWrapper.h"
#import "User.h"
#import "Transaction.h"
#import "UIImage+ScaledImage.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Curled.h"

#import "ZBarSDK.h"

@interface HomeViewController : UITableViewController <UITableViewDelegate, UIImagePickerControllerDelegate, RKObjectLoaderDelegate, ZBarReaderDelegate> {
    NSNumberFormatter *currencyFormatter;
}

@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *accountBalance;
@property (weak, nonatomic) IBOutlet UIImageView *accountImage;

- (IBAction)signOutButtonWasPressed:(id)sender;

@end
