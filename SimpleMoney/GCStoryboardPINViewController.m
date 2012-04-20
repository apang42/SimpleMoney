//
//  GCStoryboardPINViewController.m
//  
//  Adapted from:
//  GCPINViewController.m
//  Created by Caleb Davenport on 8/28/10.
//  Copyright 2010 GUI Cocoa, LLC. All rights reserved.
//  
//  by Joshua Conner on 4/18/12.
//

#import "GCStoryboardPINViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define kGCPINViewControllerDelay 0.3

@interface GCStoryboardPINViewController () 
@property (weak, nonatomic) IBOutlet UIButton *merchantNameButton;

// array of passcode entry labels
@property (nonatomic, weak) NSObject<GCStoryboardPINViewControllerDelegate> *delegate;
@property (strong, nonatomic) NSArray *labels;

// readwrite override for mode
@property (nonatomic, readwrite, assign) GCPINViewControllerMode mode;

// extra storage used when creating a passcode
@property (strong, nonatomic) NSString *text;

//set up the passcode display
- (void)setupPasscodeDisplay;

// make the passcode entry labels match the input text
- (void)updatePasscodeDisplay;

// reset user input after a set delay
- (void)resetInput;

// signal that the passcode is incorrect
- (void)wrong;
@end

@implementation GCStoryboardPINViewController
@synthesize fieldOneLabel = __fieldOneLabel;
@synthesize fieldTwoLabel = __fieldTwoLabel;
@synthesize fieldThreeLabel = __fieldThreeLabel;
@synthesize fieldFourLabel = __fieldFourLabel;
@synthesize messageLabel = __messageLabel;
@synthesize errorLabel = __errorLabel;
@synthesize inputField = __inputField;
@synthesize messageText = __messageText;
@synthesize merchantNameButton = _merchantNameButton;
@synthesize errorText = __errorText;
@synthesize labels = __labels;
@synthesize mode = __mode;
@synthesize text = __text;
@synthesize delegate = __delegate;
@synthesize confirmText = __confirmText;



#pragma mark - object methods
- (void) configureWithMode:(GCPINViewControllerMode)mode 
                 delegate:(NSObject<GCStoryboardPINViewControllerDelegate> *)delegate {
    NSAssert(mode == GCPINViewControllerModeCreate ||
             mode == GCPINViewControllerModeVerify,
             @"Invalid passcode mode");

    self.delegate = delegate;
    self.mode = mode;
    __dismiss = NO;
}

- (void)setupPasscodeDisplay {
    for (UILabel *label in self.labels) {
        label.text = @"";
    }
}

- (void)updatePasscodeDisplay {
    NSUInteger length = [self.inputField.text length];
    if (length < 4) {
        UILabel *label = [self.labels objectAtIndex:length];
        label.text = @"●";
    }
}
- (void)resetInput {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, kGCPINViewControllerDelay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        self.inputField.text = @"";
        
        for (UILabel *label in self.labels) {
            label.text = @"";
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}
- (void)wrong {
    //reset the delegate here from when we unset it before notifying OUR delegate in textField:shouldReplaceCharactersInRange:replacementString:
    self.inputField.delegate = self;
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.errorLabel.hidden = NO;
    self.text = nil;
    [self resetInput];
}


#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
    
    // setup labels list
    self.labels = [NSArray arrayWithObjects:
                   self.fieldOneLabel,
                   self.fieldTwoLabel,
                   self.fieldThreeLabel,
                   self.fieldFourLabel,
                   nil];
    
    // setup labels
    self.merchantNameButton.titleLabel.text = self.messageText;
    //self.messageLabel.text = self.messageText;
    self.errorLabel.text = self.errorText;
    self.errorLabel.hidden = YES;
	[self setupPasscodeDisplay];
    
	// setup input field
    self.inputField.hidden = YES;
    self.inputField.keyboardType = UIKeyboardTypeNumberPad;
    self.inputField.delegate = self;
    self.inputField.secureTextEntry = YES;
    self.inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.inputField becomeFirstResponder];
	
}

- (void) viewDidUnload {
    // super
    [self setMerchantNameButton:nil];
    [super viewDidUnload];
    
    // clear properties
    self.inputField.delegate = nil;
    
    self.fieldOneLabel = nil;
    self.fieldTwoLabel = nil;
    self.fieldThreeLabel = nil;
    self.fieldFourLabel = nil;
    self.messageLabel = nil;
    self.errorLabel = nil;
    self.inputField = nil;
    self.messageText = nil;
    self.errorText = nil;
    self.labels = nil;
    self.text = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsLandscape(orientation);
    }
    else {
        return (orientation == UIInterfaceOrientationPortrait);
    }
}


#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self updatePasscodeDisplay];
    NSString *input = [self.inputField.text stringByAppendingString:string];

    if ([input length] == 4) {

        if (self.mode == GCPINViewControllerModeCreate) {
            if (self.text == nil) {
                self.text = input;
                self.messageLabel.text = self.confirmText;
                [self resetInput];
            }
            else {
                if ([input isEqualToString:self.text]) {
                    //set the delegate to nil here in case the VC gets dismissed
                    self.inputField.delegate = nil;
                    
                    [self.delegate pinViewController:self didSetPIN:input];
                } else {
                    [self wrong];
                }
            }
        }
        else if (self.mode == GCPINViewControllerModeVerify) {
            //set the delegate to nil here in case the VC gets dismissed
            self.inputField.delegate = nil;
            
            [self.delegate pinViewController:self didEnterPIN:input];
        }

        return NO;
    }
    else {
        self.errorLabel.hidden = YES;
        return YES;
    }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return __dismiss;
}

#pragma mark - UI Callbacks
- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate pinViewController:self didCancel:YES];
}



@end
