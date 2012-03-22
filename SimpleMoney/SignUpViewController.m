//
//  SignUpViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"

@implementation SignUpViewController
@synthesize profileButton;
@synthesize nameTextField;
@synthesize emailTextField;
@synthesize passwordTextField;

- (void)sendRequest {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/users" delegate:self block:^(RKObjectLoader* loader) {
        RKParams *params = [RKParams params];
        [params setValue:nameTextField.text forParam:@"user[name]"];
        [params setValue:emailTextField.text forParam:@"user[email]"];
        [params setValue:passwordTextField.text forParam:@"user[password]"];
        loader.params = params;
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
        loader.method = RKRequestMethodPOST;
    }];
}

- (void)uploadProfileImageForUser:(User *)user {
    if (profileImage && user) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [objectManager putObject:user delegate:nil block:^(RKObjectLoader *loader){
            RKParams *params = [RKParams params];
            [params setValue:user.name forParam:@"user[name]"];
            [params setValue:user.email forParam:@"user[email]"];
            [params setValue:passwordTextField.text forParam:@"user[current_password]"];
            NSData *profileImageData = UIImagePNGRepresentation(profileImage);
            [params setData:profileImageData MIMEType:@"image/png" forParam:@"user[avatar]"];
            
            loader.params = params;
            loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
            loader.method = RKRequestMethodPUT;
        }];
    }
    loadingIndicator.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    loadingIndicator.mode = MBProgressHUDModeCustomView;
    [loadingIndicator hide:YES afterDelay:2];
}

- (IBAction)cancelButtonWasPressed {
    [self dismissModalViewControllerAnimated:true];
}

- (IBAction)signUpButtonWasPressed {
    [self sendRequest];
    [self dismissKeyboard];
    
    loadingIndicator = [[MBProgressHUD alloc] initWithView:self.tableView.window];
    loadingIndicator.delegate = self;
    [self.tableView.window addSubview:loadingIndicator];
    loadingIndicator.dimBackground = YES;
    [loadingIndicator show:YES];
}

- (IBAction)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)showCameraUI {
    [self startCameraControllerFromViewController: self usingDelegate: self];
}

- (IBAction)showImagePickerUI {
    [self startImagePickerFromViewController:self usingDelegate:self];
}

- (BOOL)startCameraControllerFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    // Check to see if the device has a camera, and the delegate and controller isn't nil
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (delegate == nil) || (controller == nil)) {
        return NO;   
    }
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = delegate;
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

- (BOOL)startImagePickerFromViewController:(UIViewController*) controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    // Check to see if the device has a Photo Library, and the delegate and controller isn't nil
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO) || (delegate == nil) || (controller == nil)) {
        return NO;   
    }
    UIImagePickerController *imagePickerUI = [[UIImagePickerController alloc] init];
    imagePickerUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    imagePickerUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
    imagePickerUI.allowsEditing = NO;
    imagePickerUI.delegate = delegate;
    [controller presentModalViewController:imagePickerUI animated:YES];
    return YES;
}

# pragma mark - UIImagePickerController delegate methods

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated: YES];
}

// For responding to the user accepting a newly-captured picture
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *bigImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
        if (editedImage) {
            bigImage = editedImage;
        } else {
            bigImage = originalImage;
        }
        if (!picker.title) {
            // Save the new image (original or edited) to the Camera Roll
            UIImageWriteToSavedPhotosAlbum (bigImage, nil, nil , nil);
        }
        imageToSave = [UIImage imageWithImage:bigImage scaledToSizeWithSameAspectRatio:CGSizeMake(150.0, 150.0)];
        // Set the profileButton image to the newly-captured picture
        profileImage = imageToSave;
        [profileButton setImage:imageToSave borderWidth:5.0 shadowDepth:7.0 controlPointXOffset:30.0 controlPointYOffset:75.0 forState:UIControlStateNormal];
    }
    [self dismissModalViewControllerAnimated: YES];
}

# pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self signUpButtonWasPressed];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark RKObjectLoader delegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    User *user = object;
    // Signed up successfully, let's add the user's credentials to the iOS keychain so we can sign them in automatically
    if ([user.email isEqualToString:self.emailTextField.text]) {
        NSLog(@"Attempting to save user %@", user.email);
        
        [KeychainWrapper save:@"userID" data:user.userID];
        [KeychainWrapper save:@"userEmail" data:user.email];
        [KeychainWrapper save:@"userPassword" data:self.passwordTextField.text];
    }
    [self uploadProfileImageForUser:user];
    [self performSegueWithIdentifier:@"signUpSegue" sender:self];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);
    // TODO: Display error message
}

#pragma mark RKRequest delegate methods
- (void)requestDidTimeout:(RKRequest *)request {
    NSLog(@"RKRequest did timeout");
    [loadingIndicator hide:YES];
    // TODO: Display timeout error message
}

#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    hud = nil;
}

- (void)request:(RKRequest *)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive {
    NSLog(@"RKRequest did receive data");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set the background image
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landing-bg"]];
    [backgroundImage setFrame:self.tableView.frame];
    self.tableView.backgroundView = backgroundImage;

    // Set blank profile image
    [profileButton setImage:[UIImage imageNamed:@"profile"] borderWidth:5.0 shadowDepth:7.0 controlPointXOffset:30.0 controlPointYOffset:75.0 forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.profileButton = nil;
    self.nameTextField = nil;
    self.emailTextField = nil;
    self.passwordTextField = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end