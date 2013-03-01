//
//  ViewController.h
//  PageViewController
//
//  Created by Tom Fewster on 11/01/2012.
//  Copyright (c) 2012 Naranya Apphouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INITIAL_INDEX_VALUE -3

@protocol CustomPageViewControllerDataSource

-(UIViewController *) controllerForIndex:(int)index;
-(void)didShowController:(UIViewController *)controller atIndex:(int)index;
@end
/**
 This UIViewController acts like a paged UIScrollView working with other UIViewController's instead of UIView's.
 */
@interface CustomPageViewController : UIViewController <UIScrollViewDelegate>
{
    int displayingIndex;
    BOOL isLoaded;
    int recoveryIndex;//este indice se utiliza para recuperar el estado en caso de un aviso de memoria
}
/**
 UIScrollView than is used to display the child views. If this property isn't assigned automatically is setted to a UIScrollView created by the control itself.
 */
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

/**
 Indicates the controller than is showed at the moment.
 */
@property int indexOfCurrentViewController;
/**
 Total number of pages of the control.
 */
@property (nonatomic)int numberOfPages;
/**
 Controller than actually is in memory and ready to be showed.Is placed previous to the controller than is already showed.
 */
@property (nonatomic,retain) UIViewController * previousViewController;
/**
 Controller than is currently showed.
 */
@property (nonatomic, retain) UIViewController * currentViewController;
/**
 Controller than actually is in memory and ready to be showed.Is placed forward to the controller than is already showed.
 */
@property (nonatomic, retain) UIViewController * nextViewController;
/**
 Reference to the data source object. The assignation isn't optional.
 */
@property (assign,nonatomic)  id<CustomPageViewControllerDataSource> dataSource;

/**
 Move the position of the scroller to a specific controller.
 @param index The controller index than you want to show.
 @param animated Apply animation or not.
 */
-(void)moveToIndex:(int)index animated:(BOOL)animated;
/**
 Remove all loaded controllers and get ready to load more.
 */
-(void)cleanAll;
/**
 Retrieve a controller corresponding to a specific index.
 @param index Index of the controller.
 @return The requested controller.
 */
-(UIViewController * )getControllerForIndex:(int)index;
/**
 Abstract method used to notify to a subclass about the last controller than was showed.
 @param The controller than is currently showed.
 */
-(void)notifyAboutLastShowingController:(UIViewController *)controller;

@end
