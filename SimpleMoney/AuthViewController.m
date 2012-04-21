//
//  AuthViewController.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AuthViewController.h"
#import "HomeViewController.h"

@implementation AuthViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	
    //hiding the tabBar leaves a black space where it used to be, so we also resize the main view's frame
    self.tabBarController.tabBar.hidden = YES;
    [[self.tabBarController.view.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, 320, 480)];
}

@end
