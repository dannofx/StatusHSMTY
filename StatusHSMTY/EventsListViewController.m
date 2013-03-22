//
//  EventsListViewController.m
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "EventsListViewController.h"
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
    
    NSSortDescriptor *sortDescriptorByType = [[NSSortDescriptor alloc] initWithKey:@"checkEvent" ascending:YES];
    NSSortDescriptor *sortDescriptorByDate = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByType,sortDescriptorByDate,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hackerSpace == %@", hackerSpace];
    [fetchRequest setPredicate:predicate];
    
    // Create the fetched results controller
    NSString * cacheName=@"EventContent";
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.coreDataContext
                                                                                                  sectionNameKeyPath:@"checkEvent" cacheName:cacheName];
    
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString * cellIdentifier=@"eventItemCell";
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Event * event=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleValue2
                                           reuseIdentifier:cellIdentifier] ;
    }
    
    //setea datos
    cell.eventNameLabel.text=event.name;
    
    if(event.checkEvent)
    {
            [cell setDate:event.timeDate];
        
    }
    else
        [cell setDate:event.startDate];
    
    ContentManager * contentManager=[ContentManager contentManager];
    [contentManager removeDownloadObserver:cell];
    cell.imagePath=event.imagePath;
    
    UIImage * eventImage=event.image;
    if(eventImage==nil)
    {
        cell.imageView.image=[UIImage imageNamed:@"generic.png"];
        if(event.imageURL)
        {
            DownloadRequest * request=[DownloadRequest requestForFileAt:event.imageURL savingOn:event.imagePath];
            request.downloadObserver=cell;
            request.tag=START_TAG_FOR_EVENT_IMAGES+indexPath.row;
            request.finishObserverSelector=@selector(imageDownloadFinishedSuccessfully:);

            [contentManager addDownloadItemRequest:request];
        }
    }else{
        cell.imageView.image=eventImage;

    }
    

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(![self isUpdating])
    {
        [self.navigationController pushViewController:self.carrouselViewController animated:YES];
        [self.carrouselViewController moveToIndex:indexPath.row animated:NO];
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
    NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
    detailVC.event=[self.fetchedResultsController objectAtIndexPath:indexPath];
    return detailVC;
    
    
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
