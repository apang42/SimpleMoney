//
//  AppDelegate.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#define kSERVICE_URL @"http://severe-leaf-6733.herokuapp.com/"
#define kDEBUG YES
//#define kSERVICE_URL @"http://192.168.0.104:3000"

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    [[UITabBar appearance] setTintColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [[UINavigationBar appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor colorWithHue:0 saturation:0 brightness:0.6 alpha:1], UITextAttributeTextColor,
                                                                   [UIColor whiteColor],UITextAttributeTextShadowColor,
                                                                   [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset,
                                                                   [UIFont fontWithName:@"HelveticaNeue-Bold" size:0.0],UITextAttributeFont,
                                                                   nil]];
    
    [[UIBarButtonItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [UIColor colorWithWhite:0.4 alpha:1.0], UITextAttributeTextColor,
                                                         [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                         [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset,
                                                         [UIFont fontWithName:@"HelveticaNeue-Medium" size:0.0],UITextAttributeFont,
                                                         nil] forState:UIControlStateNormal];
    
    //RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
	RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:kSERVICE_URL];
    
    // Enable automatic network activity indicator management
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"SimpleMoney.sqlite"];
    
    // Map the JSON params to our Core Data User model
    RKManagedObjectMapping* userMapping = [RKManagedObjectMapping mappingForEntityWithName:@"User"];
    userMapping.primaryKeyAttribute = @"userID";
    [userMapping mapKeyPath:@"id" toAttribute:@"userID"];
    [userMapping mapKeyPath:@"avatar_url" toAttribute:@"avatarURL"];
    [userMapping mapKeyPath:@"avatar_url_small" toAttribute:@"avatarURLsmall"];
    [userMapping mapKeyPath:@"email" toAttribute:@"email"];
    [userMapping mapKeyPath:@"password" toAttribute:@"password"];
    [userMapping mapKeyPath:@"name" toAttribute:@"name"];
    [userMapping mapKeyPath:@"balance" toAttribute:@"balance"];    

    // Map User model attributes to JSON params that our rails server understands.
    RKObjectMapping* userSerializationMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]]; 
    [userSerializationMapping mapKeyPath:@"userID" toAttribute:@"user[id]"];
    [userSerializationMapping mapKeyPath:@"email" toAttribute:@"user[email]"];
    [userSerializationMapping mapKeyPath:@"password" toAttribute:@"user[password]"];
    [userSerializationMapping mapKeyPath:@"name" toAttribute:@"user[name]"];
    [userSerializationMapping mapKeyPath:@"balance" toAttribute:@"user[balance]"];
    
    // Map the JSON params to our Core Data Transaction model
    RKManagedObjectMapping* transactionMapping = [RKManagedObjectMapping mappingForClass:[Transaction class]];
    [transactionMapping mapKeyPath:@"id" toAttribute:@"transactionID"];
    [transactionMapping mapKeyPath:@"amount" toAttribute:@"amount"];
    [transactionMapping mapKeyPath:@"sender_email" toAttribute:@"sender_email"];
    [transactionMapping mapKeyPath:@"recipient_email" toAttribute:@"recipient_email"];
    [transactionMapping mapKeyPath:@"complete" toAttribute:@"complete"];
    [transactionMapping mapKeyPath:@"description" toAttribute:@"transactionDescription"];
    [transactionMapping mapKeyPath:@"created_at" toAttribute:@"created_at"];
    [transactionMapping mapKeyPath:@"updated_at" toAttribute:@"updated_at"];
    transactionMapping.primaryKeyAttribute = @"transactionID";
        
    // Setup relationships
    [userMapping hasMany:@"transactions" withMapping:transactionMapping];
    [transactionMapping hasOne:@"recipient" withMapping:userMapping];
    [transactionMapping hasOne:@"sender" withMapping:userMapping];

    // Setup date format so our timestamps get converted into NSDate objects.
    [RKObjectMapping addDefaultDateFormatterForString:@"E MMM d HH:mm:ss Z y" inTimeZone:nil];
    
    // Register our mappings with the provider.
    [objectManager.mappingProvider setMapping:userMapping forKeyPath:@"user"];
    [objectManager.mappingProvider setSerializationMapping:userSerializationMapping forClass:[User class]];
    [objectManager.mappingProvider setMapping:transactionMapping forKeyPath:@"transaction"];

    [objectManager.router routeClass:[User class] toResourcePath:@"/users/"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
