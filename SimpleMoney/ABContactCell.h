//
//  ABContactCell.h
//  SimpleMoney
//
//  Created by Joshua Conner on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ABContactCellDelegate <NSObject>
@required
- (void)replaceEmailFieldWithName:(NSString *)name 
                         andEmail:(NSString *)email 
                     andImage:(UIImage *)image;
@end

@interface ABContactCell : UITableViewCell
@property id <ABContactCellDelegate> delegateTVC;
@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (strong, nonatomic) IBOutletCollection(UIButton)NSMutableArray *emailButtons;

- (void)configureWithDictionary:(NSDictionary *)dictionary;
- (IBAction)buttonPressed:(UIButton *)sender;
@end
