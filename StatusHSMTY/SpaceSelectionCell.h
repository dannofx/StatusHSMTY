//
//  SpaceSelectionCell.h
//  StatusHSMTY
//
//  Created by Danno on 3/4/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SpaceSelectionCellDelegate
-(void)cellAtIndex:(NSIndexPath *)indexPath changeToValue:(BOOL)value;
@end

@interface SpaceSelectionCell : UITableViewCell

@property(nonatomic,weak)id<SpaceSelectionCellDelegate> delegate;
@property(nonatomic,retain) IBOutlet UISwitch* followingSwitch;

-(IBAction)switchValueChanged:(id)sender;

@end
