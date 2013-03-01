//
//  ViewController.m
//  PageViewController
//
//  Created by Tom Fewster on 11/01/2012.
//  Copyright (c) 2012 Naranya Apphouse. All rights reserved.
//

#import "CustomPageViewController.h"


@interface CustomPageViewController ()
-(void)removeControllerFromPageControl:(UIViewController *)controller;
-(void)addControllerToPageControl:(UIViewController *)controller atIndex:(int)inde;
-(void)renewControllersForIndex:(int)index;
-(void)refreshScrollPosition:(BOOL)animated;


@end

@implementation CustomPageViewController

@synthesize scrollView;
@synthesize currentViewController;
@synthesize previousViewController;
@synthesize nextViewController;
@synthesize indexOfCurrentViewController;
@synthesize numberOfPages=_numberOfPages;
@synthesize dataSource;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if(self.scrollView==nil)
    {
        CGRect workingFrame=self.view.frame;
        workingFrame.origin.x=0;
        workingFrame.origin.y=0;
        self.scrollView=[[UIScrollView alloc] initWithFrame:workingFrame];
        self.scrollView.delegate=self;
        [self.view addSubview:self.scrollView];
    }
	[self.scrollView setPagingEnabled:YES];
    self.scrollView.clipsToBounds=YES;
	[self.scrollView setShowsHorizontalScrollIndicator:NO];
	[self.scrollView setShowsVerticalScrollIndicator:NO];
	[self.scrollView setDelegate:self];
    self.scrollView.scrollEnabled=YES;
    self.scrollView.pagingEnabled=YES;
    self.scrollView.bounces=YES;

    
	if (currentViewController.view.superview != nil) {
		[currentViewController viewWillAppear:NO];
	}
	self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * self.numberOfPages, scrollView.frame.size.height);
    isLoaded=YES;
    [self moveToIndex:self.indexOfCurrentViewController animated:NO];
    
    
    //cancelar los touch
    //UIPanGestureRecognizer *cancelPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(manageTouch:)];
    //[self.view addGestureRecognizer:cancelPan];
    
}

-(void)manageTouch:(UIGestureRecognizer *) gesture
{
    //esto solo es para que no se hereden los touch a la vista del scroll principal
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
	return NO;
}


-(void)moveToIndex:(int)index animated:(BOOL)animated
{
    if(index>=0&&index<self.numberOfPages)
    {
        self.indexOfCurrentViewController=index;
        if(isLoaded)
        {
            [self renewControllersForIndex:self.indexOfCurrentViewController];
            [self refreshScrollPosition:animated];
            [self.dataSource didShowController:currentViewController atIndex:index];
        }
    }
    

    
    
}
-(id)init
{
    self=[super init];
    if(self)
    {
        displayingIndex=INITIAL_INDEX_VALUE;
        indexOfCurrentViewController=INITIAL_INDEX_VALUE;
        recoveryIndex=INITIAL_INDEX_VALUE;
        isLoaded=NO;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if(self)
    {
        displayingIndex=INITIAL_INDEX_VALUE;
        indexOfCurrentViewController=INITIAL_INDEX_VALUE;
        recoveryIndex=INITIAL_INDEX_VALUE;
        isLoaded=NO;
    }
    return self;
}




-(void)cleanAll
{
    recoveryIndex=self.indexOfCurrentViewController;
    if(self.currentViewController)
        [self.currentViewController viewDidDisappear:NO];
    [self removeControllerFromPageControl:previousViewController];
    [self removeControllerFromPageControl:currentViewController];
    [self removeControllerFromPageControl:nextViewController];
    displayingIndex=INITIAL_INDEX_VALUE;
    indexOfCurrentViewController=INITIAL_INDEX_VALUE;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
}

-(void)removeControllerFromPageControl:(UIViewController *)controller
{
    if(controller!=nil)
    {
        [controller viewWillUnload];
        [controller.view removeFromSuperview];
        //[controller removeFromParentViewController];
        controller=nil;
        
    }
}

-(void)addControllerToPageControl:(UIViewController *)controller atIndex:(int)index
{
    if (index < 0||index >= self.numberOfPages||controller==nil)
        return;

	// add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * index;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self.scrollView addSubview:controller.view];
    }
    
}

-(UIViewController * )getControllerForIndex:(int)index
{
    if(index<0||index>=_numberOfPages)
        return nil;
    return [self.dataSource controllerForIndex:index];
}

-(void)renewControllersForIndex:(int)index
{
    int indexPreviousView=displayingIndex-1;
    int indexNextView=displayingIndex+1;
    
    if(currentViewController!=nil)
        [currentViewController viewDidDisappear:YES];
    
    if(index==indexNextView)
    {

        //remueve controladores hijos no necesarios
        [self removeControllerFromPageControl:previousViewController];
        previousViewController=nil;
        //actualiza controladores
        previousViewController=currentViewController;
        currentViewController=nextViewController;
        nextViewController=[self getControllerForIndex:index+1];
        //agrega nuevo controlador
        [self addControllerToPageControl:nextViewController atIndex:index+1];
        //actualiza index
        displayingIndex=index;
        [previousViewController viewWillDisappear:YES];
    }
    if(index==indexPreviousView)
    {
        //remueve controladores hijos no necesarios
        [self removeControllerFromPageControl:nextViewController];
        nextViewController=nil;
        //actualiza controladores
        nextViewController=currentViewController;
        currentViewController=previousViewController;
        previousViewController=[self getControllerForIndex:index-1];
        
        //agrega nuevo controlador
        [self addControllerToPageControl:previousViewController atIndex:index-1];
        //actualiza index
        displayingIndex=index;
        [nextViewController viewWillDisappear:YES];
        
    }
    if(index!=indexPreviousView&&index!=indexNextView)
    {
        //remueve controladores hijos no necesarios
        [self removeControllerFromPageControl:previousViewController];
        [self removeControllerFromPageControl:currentViewController];
        [self removeControllerFromPageControl:nextViewController];
        //actualiza controladores
        currentViewController=[self getControllerForIndex:index];
        nextViewController=[self getControllerForIndex:index+1];
        previousViewController=[self getControllerForIndex:index-1];
        //agrega nuevo controlador
        [self addControllerToPageControl:currentViewController atIndex:index];
        [self addControllerToPageControl:previousViewController atIndex:index-1];
        [self addControllerToPageControl:nextViewController atIndex:index+1];
        
        //actualiza index
        displayingIndex=index;
    }
    if(currentViewController!=nil)
    {
        [currentViewController viewDidAppear:YES];
        [self notifyAboutLastShowingController:currentViewController];
    }

}
-(void)notifyAboutLastShowingController:(UIViewController *)controller
{
    //para heredarse en caso de que sea necesario
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if(currentViewController)
    {
        [currentViewController viewDidAppear:animated];
    }

}

- (void)viewWillDisappear:(BOOL)animated {

    if(currentViewController)
    {
        [currentViewController viewWillDisappear:animated];
    }
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {

    if(currentViewController)
    {
        [currentViewController viewDidDisappear:animated];
    }
	[super viewDidDisappear:animated];
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

-(void)refreshScrollPosition:(BOOL)animated
{
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * indexOfCurrentViewController;
    frame.origin.y = 0;
    
	[self.scrollView scrollRectToVisible:frame animated:animated];
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	if (self.indexOfCurrentViewController != page) {
        [self renewControllersForIndex:page];
        self.indexOfCurrentViewController=page;
        [self.dataSource didShowController:currentViewController atIndex:page];
    }
}// called when scroll view grinds to a halt


-(void)didReceiveMemoryWarning
{
    //refresca las vistas
    if(self.indexOfCurrentViewController==INITIAL_INDEX_VALUE)
        self.indexOfCurrentViewController=recoveryIndex;
    
    [self moveToIndex:self.indexOfCurrentViewController animated:NO];
    [super didReceiveMemoryWarning];
}

-(void)setNumberOfPages:(int)numberOfPages
{
    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numberOfPages, scrollView.frame.size.height);

    _numberOfPages=numberOfPages;
}
@end
