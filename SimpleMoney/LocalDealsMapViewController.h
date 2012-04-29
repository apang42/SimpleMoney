//
//  LocalDealsMapViewController.h
//  SimpleMoney
//
//  Created by Joshua Conner on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Merchant.h"
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"

@interface LocalDealsMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *nearbyMerchants;
@property (strong, nonatomic) CLLocation *currentLocation;
@end
