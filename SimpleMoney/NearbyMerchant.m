//
//  NearbyMerchant.m
//  SimpleMoney
//
//  Created by Joshua Conner on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NearbyMerchant.h"

@implementation NearbyMerchant 
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

- (void)configureWithMerchant:(Merchant *)merchant {
    self.name = merchant.name;
    self.address = merchant.address;
    self.coordinate = CLLocationCoordinate2DMake([merchant.latitude doubleValue], [merchant.longitude doubleValue]);
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return self.address;
}
@end
