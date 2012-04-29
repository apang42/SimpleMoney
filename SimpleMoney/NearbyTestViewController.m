//
//  NearbyTestViewController.m
//  SimpleMoney
//
//  Created by Joshua Conner on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NearbyTestViewController.h"
#import "Merchant.h"

@interface NearbyTestViewController ()

@end

@implementation NearbyTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //HACK: couldn't get GET parameters to pass correctly for this call, so I'm encoding them directly into the URL because UGRADS in in 6 hours
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *resourcePath = [NSString stringWithFormat:@"/near/%f/%f", 35.185664, -111.655769];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self block:^(RKObjectLoader* loader) {

        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[Merchant class]];

        loader.method = RKRequestMethodGET;
    }];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark - RKObjectLoader Delegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"RKObjectLoader failed with error: %@", error);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    NSLog(@"Object loaded: %@", objects);
}

- (void)request:(RKRequest *)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive {
    NSLog(@"RKRequest did receive data");
}

@end
