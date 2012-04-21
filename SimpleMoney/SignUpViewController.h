//
//  SignUpViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "User.h"
#import "MBProgressHUD.h"
#import "CurledViewBase.h"
#import "KeychainWrapper.h"
#import "UIButton+Curled.h"
#import "UIImage+ScaledImage.h"
#import "UIImageView+WebCache.h"


@interface SignUpViewController : UITableViewController<UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,RKObjectLoaderDelegate, RKRequestDelegate,MBProgressHUDDelegate> {
    UIImage *profileImage;
    MBProgressHUD *loadingIndicator;
}

@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)cancelButtonWasPressed;
- (IBAction)signUpButtonWasPressed;
- (IBAction)dismissKeyboard;
- (void)sendRequest;
- (void)uploadProfileImageForUser:(User *)user;
- (IBAction)showCameraUI;
- (IBAction)showImagePickerUI;
- (BOOL)startCameraControllerFromViewController:(UIViewController*) controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate;
- (BOOL)startImagePickerFromViewController:(UIViewController*) controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate;

@end