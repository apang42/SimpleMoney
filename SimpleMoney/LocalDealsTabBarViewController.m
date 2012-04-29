//
//  LocalDealsTabBarViewController.m
//  SimpleMoney
//
//  Created by Joshua Conner on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocalDealsTabBarViewController.h"

@interface LocalDealsTabBarViewController ()

@end

@implementation LocalDealsTabBarViewController
@synthesize nearbyMerchants = _nearbyMerchants;
@synthesize currentLocation = _currentLocation;

//set the nearbyMerchants arrays for the two child views
- (void) viewDidLoad {
    for (UIViewController *controller in self.viewControllers) {
        if ([controller respondsToSelector:@selector(setNearbyMerchants:)]) {
            [controller performSelector:@selector(setNearbyMerchants:) withObject:self.nearbyMerchants];
        }
        
        if ([controller respondsToSelector:@selector(setCurrentLocation:)]) {
            NSLog(@"Setting current location %@ for VC %@", self.currentLocation, [controller class]);
            [controller performSelector:@selector(setCurrentLocation:) withObject:self.currentLocation];
        }
    }
}
@end
