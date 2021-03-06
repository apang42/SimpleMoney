//
//  Transaction.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Transaction : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * complete;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * recipient_email;
@property (nonatomic, retain) NSString * sender_email;
@property (nonatomic, retain) NSString * transactionDescription;
@property (nonatomic, retain) NSNumber * transactionID;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) User *recipient;
@property (nonatomic, retain) User *sender;
@property (nonatomic, retain) User *user;

@end
