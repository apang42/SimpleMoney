//
//  NearbyMerchant.h
//  SimpleMoney
//
//  Created by Joshua Conner on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"
#import "Merchant.h"

@interface NearbyMerchant : NSObject <MKAnnotation>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (void)configureWithMerchant:(Merchant *)merchant;
@end
