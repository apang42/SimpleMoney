//
//  TransactionTextField.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionTextField : UITextField {
    CGRect rect;
}

- (CGRect)indentedRectForBounds:(CGRect)bounds;

@end
