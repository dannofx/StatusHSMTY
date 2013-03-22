//
//  SpaceSelectorController.h
//  StatusHSMTY
//
//  Created by Danno on 3/1/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSMTYViewController.h"
#import "SpaceSelectionCell.h"
#import <CoreData/CoreData.h>


@interface SpaceSelectorController : HSMTYViewController<NSFetchedResultsControllerDelegate,UISearchDisplayDelegate,SpaceSelectionCellDelegate>


-(IBAction)cancel;
-(IBAction)updateList;

@end
