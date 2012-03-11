//
//  SignUpViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurledViewBase.h"
#import "UIButton+Curled.h"

@interface SignUpViewController : UITableViewController<UIActionSheetDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)profileImageWasPressed;
- (IBAction)cancelButtonWasPressed;
- (IBAction)dismissKeyboard;
@end
