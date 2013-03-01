//
//  EventsListViewController.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSMTYViewController.h"
#import "CustomPageViewController.h"


@interface EventsListViewController : HSMTYViewController<NSFetchedResultsControllerDelegate,CustomPageViewControllerDataSource>

@end
