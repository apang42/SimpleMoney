//
//  LocalDealsMapViewController.m
//  SimpleMoney
//
//  Created by Joshua Conner on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocalDealsMapViewController.h"
#import "NearbyMerchant.h"

@interface LocalDealsMapViewController () {
    CLLocationManager *locationManager;
}
@property (strong, nonatomic) NSMutableArray *merchantGeopoints;
@end

@implementation LocalDealsMapViewController
@synthesize mapView = _mapView;
@synthesize nearbyMerchants = _nearbyMerchants;
@synthesize merchantGeopoints = _merchantGeopoints;
@synthesize currentLocation = _currentLocation;

- (NSMutableArray *)merchantGeopoints {
    if (!_merchantGeopoints) {
        _merchantGeopoints = [[NSMutableArray alloc] initWithCapacity:10]; //a guess
    }
    return _merchantGeopoints;
}


#pragma mark- View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        [self createGeopointsFromArray:self.nearbyMerchants];
        [self addAndSizeMapWithGeopoints:self.merchantGeopoints];
   
}

- (void)addAndSizeMapWithGeopoints:(NSArray *)geopoints {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.currentLocation.coordinate);
        MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    
    for (id <MKAnnotation> annotation in self.merchantGeopoints)
    {
        [self.mapView addAnnotation:annotation];
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
  
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self.mapView setVisibleMapRect:zoomRect animated:NO];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)createGeopointsFromArray:(NSArray *)array {
    if (array) {
        for (Merchant *m in array) {
            NearbyMerchant *near = [[NearbyMerchant alloc] init];
            [near configureWithMerchant:m];
            [self.merchantGeopoints addObject:near];
        }
    }
}

@end
