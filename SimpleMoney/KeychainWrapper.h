//
//  KeychainWrapper.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KeychainWrapper;

@interface KeychainWrapper : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end