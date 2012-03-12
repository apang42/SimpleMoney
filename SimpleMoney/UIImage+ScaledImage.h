//
//  UIImage+ScaledImage.h
//  SimpleMoney
//
//  Created by Arthur Pang on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#include <math.h>

@interface UIImage (ScaledImage)
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
@end
