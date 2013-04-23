//
//  AboutController.h
//  StatusHSMTY
//
//  Created by Danno on 23/04/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutController : UIViewController<UIActionSheetDelegate>

-(IBAction)designerSite:(id)sender;
-(IBAction)asihttpSite:(id)sender;
-(IBAction)stkeychainSite:(id)sender;
-(IBAction)hudSite:(id)sender;

@property (nonatomic,retain) IBOutlet UILabel * versionLabel;

@end
