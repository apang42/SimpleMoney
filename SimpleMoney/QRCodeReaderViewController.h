//
//  QRCodeReaderViewController.h
//  SimpleMoney
//
//  Created by Joshua Conner on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/Restkit.h>
#import "ZBarSDK.h"
#import "GCStoryboardPINViewController.h"
#import "MBProgressHUD.h"

@interface QRCodeReaderViewController : UIViewController <ZBarReaderViewDelegate, GCStoryboardPINViewControllerDelegate, MBProgressHUDDelegate, RKObjectLoaderDelegate> {
    ZBarCameraSimulator *cameraSim;
}

//UI
@property (weak, nonatomic) IBOutlet UIImageView *iphoneImage;
@property (weak, nonatomic) IBOutlet UIView *greenSquare;
@property (weak, nonatomic) IBOutlet ZBarReaderView *readerView;

@end
