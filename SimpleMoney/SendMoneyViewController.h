//
//  SendMoneyViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "KeychainWrapper.h"
#import "User.h"
#import "Transaction.h"
@interface SendMoneyViewController : UIViewController <UITextFieldDelegate, RKObjectLoaderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

- (IBAction)sendMoneyButtonWasPressed;
- (IBAction)dismissKeyboard;
@end
