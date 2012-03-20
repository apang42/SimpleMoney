//
//  InitialViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InitialViewController.h"

@implementation InitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *userEmail = [KeychainWrapper load:@"userEmail"];
    NSString *userPassword = [KeychainWrapper load:@"userPassword"];
    
    //[KeychainWrapper delete:@"userEmail"];
    //[KeychainWrapper delete:@"userPassword"];
    
    NSLog(@"keychain email: %@", userEmail);
    NSLog(@"keychain password: %@", userPassword);
    
    if (!userEmail || !userPassword) {
        [self performSegueWithIdentifier:@"authSegue" sender:self];
    } else {
        // If the user is not signed in, sign them in before we move to the home view
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [objectManager loadObjectsAtResourcePath:@"/users/sign_in" delegate:self block:^(RKObjectLoader* loader) {
            RKParams *params = [RKParams params];
            [params setValue:userEmail forParam:@"user[email]"];
            [params setValue:userPassword forParam:@"user[password]"];
            loader.params = params;
            loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[User class]];
            loader.method = RKRequestMethodPOST;
        }];
        [self performSegueWithIdentifier:@"homeSegue" sender:self];
    }
}

# pragma mark - RKObjectLoader Delegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    NSLog(@"loaded: %@",object);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
