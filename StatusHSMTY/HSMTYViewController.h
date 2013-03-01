//
//  HSMTYViewController.h
//  StatusHSMTY
//
//  Created by Danno on 2/20/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface HSMTYViewController : UITableViewController
@property (nonatomic,assign) NSManagedObjectContext * coreDataContext;

-(IBAction)performUpdate:(id)sender;
-(BOOL)isUpdating;

-(void)spaceWasUpdatedWithName:(NSString *)spaceName coreDataID:(NSManagedObjectID *)coreDataID;

@end
