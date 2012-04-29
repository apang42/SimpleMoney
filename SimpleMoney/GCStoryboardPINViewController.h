//
//  GCStoryboardPINViewController.h
//  
//  Adapted from:
//  GCPINViewController.h
//  Created by Caleb Davenport on 8/28/10.
//  Copyright 2010 GUI Cocoa, LLC. All rights reserved.
//  
//  by Joshua Conner on 4/18/12.
//

#import <UIKit/UIKit.h>

@protocol GCStoryboardPINViewControllerDelegate;

typedef enum {
    
    /*
     
     Create a new passcode. This allows the user to enter a new passcode then
     imediately verify it.
     
     */
    GCPINViewControllerModeCreate = 0,
    
    /*
     
     Verify a passcode. This allows the user to input a passcode then have it
     checked by the caller.
     
     */
    GCPINViewControllerModeVerify
    
} GCPINViewControllerMode;

/*
 
 This class defines a common passcode control that can be dropped into an app.
 It behaves exactly like the passcode screens that can be seen by going to
 Settings > General > Passcode Lock.
 
 */
@interface GCStoryboardPINViewController : UIViewController <UITextFieldDelegate> {
@private
    BOOL __dismiss;
}

/*
 
 Set the text to display text above the input area.
 
 */
@property (nonatomic, strong) NSString *messageText;


/*
 
 Set the text for the "Business Name" button
 
 */
@property (nonatomic, strong) NSString *businessNameText;
/*
 
 Set the text to display on PIN confirmation.
 
 */
@property (nonatomic, strong) NSString *confirmText;

/*
 
 Set the text to display below the input area when the passcode fails
 verification.
 
 */
@property (nonatomic, strong) NSString *errorText;


/*
 
 Refer to `GCPINViewControllerMode`. This can only be set through the
 designated initializer.
 
 */
@property (nonatomic, readonly, assign) GCPINViewControllerMode mode;


/*
 
 If we're in "set pin" mode, this keeps track of the first pin entered to ch
 
 */
//UI properties
@property (nonatomic, strong) IBOutlet UILabel *fieldOneLabel;
@property (nonatomic, strong) IBOutlet UILabel *fieldTwoLabel;
@property (nonatomic, strong) IBOutlet UILabel *fieldThreeLabel;
@property (nonatomic, strong) IBOutlet UILabel *fieldFourLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet UITextField *inputField;
@property (nonatomic) BOOL isRequestingMoney;



/*
 
 Create a new passcode view controller providing the nib name, bundle, and
 desired mode. This is the designated initializer.
 
 */
- (void) configureWithMode:(GCPINViewControllerMode)mode delegate:(NSObject<GCStoryboardPINViewControllerDelegate> *)delegate;

/*
 
 The delegate calls this when the user enters the wrong passcode
 
 */
- (void)wrong;
@end

/*
 
 Protocol for the instantiating viewcontroller to adhere to
 
 */
@protocol GCStoryboardPINViewControllerDelegate <NSObject>
@optional
/*
 
 Called when the user enters a PIN
 
 */
- (void) pinViewController:(GCStoryboardPINViewController *)controller didEnterPIN:(NSString *)PIN;
- (void) pinViewController:(GCStoryboardPINViewController *)controller didSetPIN:(NSString *)PIN;
- (void) pinViewController:(GCStoryboardPINViewController *)controller didCancel:(BOOL)cancel;
@end

