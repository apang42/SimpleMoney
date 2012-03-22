//
//  HomeViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController (PrivateMethods)
- (void)signOut;
@end

@implementation HomeViewController
@synthesize accountName;
@synthesize accountBalance;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"/users/%@", [KeychainWrapper load:@"userID"]] delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.accountName.text = [KeychainWrapper load:@"userEmail"];
    self.accountBalance.text = [NSString stringWithFormat:@"Balance: %@", [[KeychainWrapper load:@"userBalance"] stringValue]];
    NSString *avatarURL = [KeychainWrapper load:@"userAvatarSmall"];
    if ([avatarURL isEqualToString:@"/images/small/missing.png"]) {
        
    } else {
        [self.accountImage setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"profile.png"]
                                    success:^(UIImage *image) {}
                                    failure:^(NSError *error) {}];
    }
    self.accountImage.layer.cornerRadius = 5.0;
    self.accountImage.layer.masksToBounds = YES;
    
    
}

// Sends a DELETE request to /users/sign_out
- (IBAction)signOutButtonWasPressed:(id)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/users/sign_out" delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
        loader.method = RKRequestMethodDELETE;
    }];
    [self performSegueWithIdentifier:@"loggedOutSegue" sender:self];
    [KeychainWrapper delete:@"userEmail"];
    [KeychainWrapper delete:@"userPassword"];
}

# pragma mark - RKObjectLoader Delegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    User *user = object;
    self.accountName.text = user.email;
    self.accountBalance.text = [NSString stringWithFormat:@"Balance: %@", [user.balance stringValue]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
