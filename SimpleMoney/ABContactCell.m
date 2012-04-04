//
//  ABContactCell.m
//  SimpleMoney
//
//  Created by Joshua Conner on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABContactCell.h"
#define EMAIL_BUTTON_OFFSET 50

@implementation ABContactCell {
    BOOL init;
    BOOL cellIsOpen;
}
@synthesize name = _name;
@synthesize subtitle = _subtitle;
@synthesize picture = _picture;
@synthesize arrow;
@synthesize emailButtons = _emailButtons;
@synthesize delegateTVC;

#pragma mark - Property getters and setters
- (NSMutableArray *)emailButtons {
    if (!_emailButtons) {
        _emailButtons = [[NSMutableArray alloc] init];
    }
    return _emailButtons;
}

#pragma mark - TableViewCell required methods
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (init) {
        if ([self.reuseIdentifier isEqualToString:@"multipleEmails"]) {
            //hide the "tap to select email..." label and rotate the "disclosure triangle"
            if (selected && !cellIsOpen) {
                //we use the cellIsOpen BOOL because sometimes setSelected gets called on a cell multiple times
                cellIsOpen = YES;
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void){
                    self.arrow.transform = CGAffineTransformRotate(self.arrow.transform, 1.5*M_PI);
                    self.subtitle.alpha = 0.0;
                    
                    for (UIButton *button in self.emailButtons) {
                        button.alpha = 1.0;
                    }
                } completion:^(BOOL finished){}];
            } else if (!selected && cellIsOpen) {
                cellIsOpen = NO;
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
                    self.arrow.transform = CGAffineTransformRotate(self.arrow.transform, 0.5*M_PI);
                    self.subtitle.alpha = 1.0;
                    
                    for (UIButton *button in self.emailButtons) {
                        button.alpha = 0.0;
                    }
                } completion:^(BOOL finished){}];

            }
        }
    } else {
        init = YES;
    }
    
}

#pragma mark - Cell config
- (void)configureWithDictionary:(NSDictionary *)dictionary {
    self.name.text = [dictionary objectForKey:@"name"];

    NSArray *emails = [dictionary objectForKey:@"emails"];
    int offset = 30;
    
    //if only one email address, show it
    if ([emails count] == 1) {
        self.subtitle.text = [emails lastObject];
    } else {
        for (NSString *email in emails) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self
                       action:@selector(buttonPressed:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:email forState:UIControlStateNormal];
            button.alpha = 0.0;
            button.frame = CGRectMake(45.0, offset, 220.0, 30.0);
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
            button.titleEdgeInsets = UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0);
            button.titleLabel.textColor = [UIColor darkTextColor];
            
            [self.name.superview addSubview:button];
            [self.emailButtons addObject:button];
            
            offset += 35;
        }
    }
}

- (IBAction)buttonPressed:(UIButton *)sender {

    if (self.delegateTVC && [self.delegateTVC respondsToSelector:@selector(replaceEmailFieldWithName:andEmail:)]) {
        [self.delegateTVC performSelector:@selector(replaceEmailFieldWithName:andEmail:) withObject:self.name.text withObject:sender.titleLabel.text];
    }
}

@end
