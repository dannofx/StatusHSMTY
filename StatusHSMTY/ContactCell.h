//
//  ContactCell.h
//  StatusHSMTY
//
//  Created by Danno on 22/04/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    SpecialActionMail,
    SpecialActionPhone,
    SpecialActionNone,

}SpecialAction;

@protocol ContactCellDelegate <NSObject>

-(void)cellRequestForCopy:(NSIndexPath *)index;
-(void)cellRequestForUserAction:(NSIndexPath *)index;

@end

@interface ContactCell : UITableViewCell
@property (nonatomic,assign) id<ContactCellDelegate> contactDelegate;
@property (nonatomic,retain) NSIndexPath * index;

@property (nonatomic,retain) IBOutlet UILabel * contactTypeLabel;
@property (nonatomic,retain) IBOutlet UILabel * contactInfoLabel;
@property (nonatomic,retain) IBOutlet UIImageView * contactImageView;
@property (nonatomic,retain) IBOutlet UIButton * specialActionButton;
@property (nonatomic,retain) IBOutlet UIButton * regularActionButton;
@property (nonatomic)SpecialAction specialAction;

-(IBAction)copyAction:(id)sender;
-(IBAction)launchUserAction:(id)sender;

@end
