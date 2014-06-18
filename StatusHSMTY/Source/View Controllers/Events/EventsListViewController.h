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

#ifndef ROW_SIZES
#define ROW_SIZES

#define SPECIAL_ROW_HEIGHT  79
#define REGULAR_ROW_HEIGHT 52

#endif


@interface EventsListViewController : HSMTYViewController<NSFetchedResultsControllerDelegate,CustomPageViewControllerDataSource>

@end
