//
//  Transaction.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Transaction : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSNumber * complete;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * recipient_email;
@property (nonatomic, retain) NSString * sender_email;
@property (nonatomic, retain) NSString * transactionDescription;
@property (nonatomic, retain) NSNumber * transactionID;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSManagedObject *user;

@end
