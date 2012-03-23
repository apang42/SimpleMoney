//
//  SignInViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "KeychainWrapper.h"
#import "User.h"
#import "MBProgressHUD.h"

@interface SignInViewController : UITableViewController<UITextFieldDelegate, RKObjectLoaderDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *loadingIndicator;
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)cancelButtonWasPressed;
- (IBAction)signUpButtonWasPressed;
- (IBAction)dismissKeyboard;

@end
