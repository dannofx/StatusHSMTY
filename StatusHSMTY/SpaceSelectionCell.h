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
@property(nonatomic,retain) IBOutlet UIImageView* selectionImageView;
@property (nonatomic,retain) IBOutlet UILabel * spaceNameLabel;

-(IBAction)switchValueChanged:(id)sender;
-(void)configureForAlerts:(BOOL)manageAlerts;
-(void)setAsSelectedSpace:(BOOL)selected;

@end
