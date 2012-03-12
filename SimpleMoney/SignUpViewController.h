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
#import "CurledViewBase.h"
#import "UIButton+Curled.h"
#import "User.h"

@interface SignUpViewController : UITableViewController<UIActionSheetDelegate,UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,RKObjectLoaderDelegate, RKRequestDelegate>

@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)profileImageWasPressed;
- (IBAction)cancelButtonWasPressed;
- (IBAction)dismissKeyboard;

- (void)sendRequest;

- (IBAction)showCameraUI;
- (BOOL)startCameraControllerFromViewController:(UIViewController*) controller
                                  usingDelegate:(id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>) delegate;
- (IBAction)showImagePickerUI;
- (BOOL)startImagePickerFromViewController:(UIViewController*) controller
                                  usingDelegate:(id <UIImagePickerControllerDelegate,
                                                 UINavigationControllerDelegate>) delegate;

@end
