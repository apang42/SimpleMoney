//
//  LocalDealsTabBarViewController.h
//  SimpleMoney
//
//  Created by Joshua Conner on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"

@interface LocalDealsTabBarViewController : UITabBarController
@property (strong, nonatomic) NSArray *nearbyMerchants;
@property (strong, nonatomic) CLLocation *currentLocation;
@end
