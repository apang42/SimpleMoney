//
//  Transaction.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Transaction : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSNumber * complete;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * recipient_id;
@property (nonatomic, retain) NSNumber * sender_id;
@property (nonatomic, retain) NSString * transactionDescription;
@property (nonatomic, retain) NSNumber * transactionID;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) User *user;

@end
