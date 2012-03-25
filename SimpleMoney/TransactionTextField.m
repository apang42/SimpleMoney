//
//  TransactionTextField.m
//  SimpleMoney
//
//  Created by Arthur Pang on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TransactionTextField.h"
#define kIDENT 10.0

@implementation TransactionTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)indentedRectForBounds:(CGRect)bounds {
    rect = CGRectMake(bounds.origin.x + kIDENT, bounds.origin.y, bounds.size.width - 2.0*kIDENT, bounds.size.height);
    return rect;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [self indentedRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self indentedRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self indentedRectForBounds:bounds];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
