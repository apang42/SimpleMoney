//
//  InitialViewController.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "KeychainWrapper.h"
#import "AuthViewController.h"
#import "HomeViewController.h"

@interface InitialViewController : UIViewController <RKObjectLoaderDelegate>

@end
