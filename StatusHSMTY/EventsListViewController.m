//
//  EventsListViewController.m
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "EventsListViewController.h"
#import "NSDate+HSMTYFormats.h"
#import "HackerSpaceInfo.h"
#import "ContentManager.h"
#import "Configuration.h"
#import "Event.h"
#import "EventCell.h"
#import "Notifications.h"
#import "DetailedEventViewController.h"
#import "GlobalConstants.h"

@interface EventsListViewController ()
{
    HackerSpaceInfo * hackerSpace;
}
@property(nonatomic,retain) CustomPageViewController * carrouselViewController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

-(void)configureRegularCellEvent:(EventCell *)cell withEvent:(Event *)event;
-(void)configureSpecialCellEvent:(EventCell *)cell withEvent:(Event *)event andtag:(NSInteger)tag;

@end

@implementation EventsListViewController
@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize carrouselViewController=_carrouselViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    hackerSpace=[[ContentManager contentManager] spaceInfoForName:[Configuration currentSpaceName]];
    self.title=@"Events";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CustomPageViewController *)carrouselViewController
{
    if(_carrouselViewController==nil)
    {
        _carrouselViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"carrouselEvents"];
        _carrouselViewController.dataSource=self;
        _carrouselViewController.numberOfPages=[[self.fetchedResultsController fetchedObjects] count];
        _carrouselViewController.navigationItem.title=NSLocalizedString(@"Events",@"Events");
        
        
    }
    return _carrouselViewController;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    if(hackerSpace==nil||hackerSpace.url==nil)
        return nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Event class]) inManagedObjectContext:self.coreDataContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:10];
    
    NSSortDescriptor *sortDescriptorByStandar = [[NSSortDescriptor alloc] initWithKey:@"standarEvent" ascending:YES];
    NSSortDescriptor *sortDescriptorByDate = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByStandar,sortDescriptorByDate,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hackerSpace == %@", hackerSpace];
    [fetchRequest setPredicate:predicate];
    
    // Create the fetched results controller
    NSString * cacheName=@"EventContent";
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataContext
                                                sectionNameKeyPath:@"standarEvent" cacheName:cacheName];
    
    
    [NSFetchedResultsController deleteCacheWithName:cacheName];
    
    // Fetch the data
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    __fetchedResultsController=aFetchedResultsController;
    __fetchedResultsController.delegate = self;
    
    return __fetchedResultsController;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSString * nativeName=[sectionInfo name];
    if([nativeName isEqualToString:@"0"])
        nativeName=NSLocalizedString(@"proximosEventos", @"Próximos eventos");
    else
        nativeName=NSLocalizedString(@"entradasSalidas",@"Entradas - Salidas");
    
    return nativeName;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.fetchedResultsController==nil)
        return 0;
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.fetchedResultsController==nil)
        return 0;

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event * event=[self.fetchedResultsController objectAtIndexPath:indexPath];

    if(event.type==EVENT_TYPE_CUSTOM)
         return SPECIAL_ROW_HEIGHT;
    else
         return REGULAR_ROW_HEIGHT;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    Event * event=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    static NSString * cellIdentifier=@"eventItemCell";
    static NSString * specialCellIdentifier=@"specialEventItemCell";
    EventCell *cell ;
    if(event.type==EVENT_TYPE_CUSTOM)
    {
        cell= [tableView dequeueReusableCellWithIdentifier:specialCellIdentifier];
        if (cell == nil)
            cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleValue2
                                    reuseIdentifier:specialCellIdentifier] ;
        
        [self configureSpecialCellEvent:cell withEvent:event
                                 andtag:(START_TAG_FOR_EVENT_IMAGES+indexPath.row)];
        
    }
    else{
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
            cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleValue2
                                    reuseIdentifier:cellIdentifier] ;
        
        [self configureRegularCellEvent:cell withEvent:event];
        

    }
    


    return cell;
}

-(void)configureRegularCellEvent:(EventCell *)cell withEvent:(Event *)event
{
    cell.eventNameLabel.text=event.name;
    cell.dateLabel.text=[event.timeDate stringDateWithShortFormat];
    if(event.type==EVENT_TYPE_CHECKIN)
        cell.imageView.image=[UIImage imageNamed:@"entradamini.png"];
    else
        cell.imageView.image=[UIImage imageNamed:@"salidamini.png"];
}
-(void)configureSpecialCellEvent:(EventCell *)cell withEvent:(Event *)event andtag:(NSInteger)tag
{
    ContentManager * contentManager=[ContentManager contentManager];
    [contentManager removeDownloadObserver:cell];
    cell.imagePath=event.imagePath;
    [cell addBorder];
    cell.dateLabel.text=[event.startDate stringDateWithCompleteFormat];
    cell.eventNameLabel.text=event.name;
    UIImage * eventImage=event.image;
    if(eventImage==nil)
    {
        
        cell.imageView.image=[UIImage imageNamed:@"eventdefault.png"];
        if(event.imageURL)
        {
            DownloadRequest * request=[DownloadRequest requestForFileAt:event.imageURL savingOn:event.imagePath];
            request.downloadObserver=cell;
            request.tag=tag;
            request.finishObserverSelector=@selector(imageDownloadFinishedSuccessfully:);
            
            [contentManager addDownloadItemRequest:request];
        }
    }else{
        cell.imageView.image=eventImage;
        
    }

}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(![self isUpdating])
    {
        NSInteger carrouselIndex=[self globalIndexFromIndexPath:indexPath];
        NSLog(@"SeBUSCARA %d",carrouselIndex);
        [self.navigationController pushViewController:self.carrouselViewController animated:YES];
        [self.carrouselViewController moveToIndex:carrouselIndex animated:NO];
    }
    else{
        [Notifications launchErrorBox:nil message:NSLocalizedString(@"espereaactualizacion",@"Espere a que termine la actualización para ver contenido.")];
    }
}



#pragma mark - Fetched Result Controller Delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
            // Data was inserted -- insert the data into the table view
        case NSFetchedResultsChangeInsert:
            _carrouselViewController=nil;
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            // Data was deleted -- delete the data from the table view
        case NSFetchedResultsChangeDelete:
            _carrouselViewController=nil;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            // Data was updated (changed) -- reconfigure the cell for the data
        case NSFetchedResultsChangeUpdate:
        {
            //No debe de pasar
        }
            break;
            // Data was moved -- delete the data from the old location and insert the data into the new location
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark CustomPageViewControllerDataSource

-(UIViewController *) controllerForIndex:(int)index{
    
    DetailedEventViewController * detailVC=[self.storyboard instantiateViewControllerWithIdentifier:@"detailItemEvent"];
    NSIndexPath *indexPath=[self indexPathForCarrouselIndex:index];
    detailVC.event=[self.fetchedResultsController objectAtIndexPath:indexPath];
    return detailVC;
    
}
-(NSInteger)globalIndexFromIndexPath:(NSIndexPath *)indexPath
{
    NSInteger reachedIndex=0;
    NSInteger lastSection=0;
    
    for(id <NSFetchedResultsSectionInfo> sectionInfo  in [self.fetchedResultsController sections])
    {
        if(lastSection==indexPath.section)
        {
            reachedIndex+=indexPath.row;
            break;
        }
        else{
            reachedIndex+=[sectionInfo numberOfObjects];

        }
        lastSection++;
    }
    return reachedIndex;
    
}
-(NSIndexPath *)indexPathForCarrouselIndex:(NSInteger)index
{
    NSInteger reachedIndex=0;
    NSInteger foundIndex=0;
    NSInteger lastSection=0;
    
    for(id <NSFetchedResultsSectionInfo> sectionInfo  in [self.fetchedResultsController sections])
    {
        NSInteger elementsPerSection=[sectionInfo numberOfObjects];
        if(((reachedIndex+elementsPerSection)-1)<index)
        {
            reachedIndex+=elementsPerSection;
             lastSection++;
        }
        else
        {
            foundIndex=index-reachedIndex;
            //se busca
        }
       
    }
    
    NSLog(@"Se busca %d se encuentra con index %d seccion %d",index,foundIndex,lastSection);
    return [NSIndexPath indexPathForRow:foundIndex inSection:lastSection];
}
-(void)didShowController:(UIViewController *)controller atIndex:(int)index{
    
}

#pragma mark - Data was updated
-(void)spaceWasUpdatedWithName:(NSString *)spaceName coreDataID:(NSManagedObjectID *)coreDataID
{
    if(hackerSpace)
        [self.coreDataContext refreshObject:hackerSpace mergeChanges:NO];
    
    hackerSpace=(HackerSpaceInfo *)[self.coreDataContext objectWithID:coreDataID];
    __fetchedResultsController=nil;
    [self.tableView reloadData];
}

@end
