//
//  ContentManager.m
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "ContentManager.h"
#import "GlobalConstants.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "AppDelegate.h"
#import "Notifications.h"
#import "Configuration.h"

#import "Contact.h"
#import "Event.h"

@interface ContentManager()
{
    ASINetworkQueue * networkDownloadQueue;
}
    @property (nonatomic,assign) NSManagedObjectContext * coreDataContext;
    -(void)contentDownloadedSuccessfully:(ASIHTTPRequest *) request;
    -(void)contentDownloadFailed:(ASIHTTPRequest *) request;
    -(void)spaceListDownloadedSuccessfully:(ASIHTTPRequest *) request;
    -(void)spaceListDownloadFailed:(ASIHTTPRequest *) request;
    -(void)downloadQueueFailed:(ASIHTTPRequest *)request;
    -(void)updateCurrentSpaceWithData:(NSDictionary *)dictionary;
    -(void)activateLoadingNotifier:(BOOL)activate;
    -(void)setInUpdateState:(BOOL)updating;
    -(void)updateSpacesListWithDictionary:(NSDictionary *)dictionary;
    -(NSArray *)allSpacesWithName:(NSString *)spaceName;
    -(HackerSpaceInfo *)preparedSpaceForUpdateWithName:(NSString *)spaceName;
    -(void)singletonInit;
    + (id)hiddenAlloc;
@end
@implementation ContentManager
@synthesize coreDataContext=_coreDataContext;
@synthesize updating=_updating;
@synthesize selectionDelegate;

-(NSManagedObjectContext *)coreDataContext{
    
    if(_coreDataContext==nil)
    {
        _coreDataContext=((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;;
    }
    return _coreDataContext;
}

+ (id)hiddenAlloc {
    return [super alloc];
}
+ (id)alloc {
    NSLog(@"%@: use +contentManager instead of +alloc", [[self class] description]);
    return nil;
}
+ (id)new {
    return [self alloc];
}
+ (id)allocWithZone:(NSZone *)zone {
    return [super allocWithZone:zone];
}
- (id)copyWithZone:(NSZone *)zone
{ // -copy inherited from NSObject calls -copyWithZone:
    NSLog(@"Contentmanagerr: attempt to -copy may be a bug."); 
    return self;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
    
    return [self copyWithZone:zone];
}
-(void)setInUpdateState:(BOOL)updating
{
    _updating=updating;

}
+ (ContentManager *)contentManager {
    static ContentManager *unicInstance = nil;
    if (!unicInstance)
    {

        unicInstance = [[self hiddenAlloc] init];
        [unicInstance singletonInit];
    }
    return unicInstance;
    
}

-(void)singletonInit
{
    networkDownloadQueue=[[ASINetworkQueue alloc] init];
    networkDownloadQueue.showAccurateProgress=YES;
    [networkDownloadQueue setDownloadProgressDelegate:self];
    [networkDownloadQueue setDelegate:self];
    [networkDownloadQueue setRequestDidFailSelector:@selector(downloadQueueFailed:)];
    [self setInUpdateState:NO];
}

#pragma mark - User methods
-(void)launchContentUpdate
{
    NSString * spaceURL=[Configuration currentSpaceAPIURL];
    if(spaceURL!=nil)
    {
        [self launchContentUpdateWithURL:spaceURL];
    }else{
        if(self.selectionDelegate)
            [self.selectionDelegate requestForhackerSpaceSelection];
    }

}

-(void)launchSpaceListUpdate
{
    if(self.updating)
        return;
    [self setInUpdateState:YES];
    [self activateLoadingNotifier:YES];
    NSURL *url = [NSURL URLWithString:LIST_SPACES_URL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:TIMEOUT_HIGH_PRIORITY];
    [request setDidFinishSelector:@selector(spaceListDownloadedSuccessfully:)];
    [request setDidFailSelector:@selector(spaceListDownloadFailed:)];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

-(void)launchContentUpdateWithURL:(NSString *)hackersURL
{
    if(self.updating)
        return;
    [self setInUpdateState:YES];
    [self activateLoadingNotifier:YES];
    NSURL *url = [NSURL URLWithString:hackersURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:TIMEOUT_HIGH_PRIORITY];
    [request setDidFinishSelector:@selector(contentDownloadedSuccessfully:)];
    [request setDidFailSelector:@selector(contentDownloadFailed:)];
    [request setDelegate:self];
    [request startAsynchronous];
    
}



#pragma mark - Private Methods

-(void)contentDownloadedSuccessfully:(ASIHTTPRequest *) request
{
    NSError * error;
    NSDictionary * jsonDictionary=[NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
    
    
    if(error!=nil)
    {
        NSLog(@"ERROR: El servidor envio un formato de respuesta no esperado.");
        [self contentDownloadFailed:request];
        return;
    }
    [self updateCurrentSpaceWithData:jsonDictionary];
    
    
}
-(void)contentDownloadFailed:(ASIHTTPRequest *) request
{
    [Notifications launchErrorBox:self message:NSLocalizedString(@"erroractualizacion", @"Update error")];
    [self activateLoadingNotifier:NO];
    [self setInUpdateState:NO];
}

-(void)spaceListDownloadedSuccessfully:(ASIHTTPRequest *) request
{
    NSError * error;
    NSDictionary * jsonDictionary=[NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
    
    
    if(error!=nil)
    {
        NSLog(@"ERROR: El servidor envio un formato de respuesta no esperado.");
        [self spaceListDownloadFailed:request];
        return;
    }
    [self updateSpacesListWithDictionary:jsonDictionary];
    
}
-(void)spaceListDownloadFailed:(ASIHTTPRequest *) request
{
    [Notifications launchErrorBox:self message:NSLocalizedString(@"erroractualizacion", @"Update error")];
    [self activateLoadingNotifier:NO];
    [self setInUpdateState:NO];
}

-(void)downloadQueueFailed:(ASIHTTPRequest *)request
{
    //TODO: Implement
}

-(HackerSpaceInfo *)createHackerSpaceWithName:(NSString *)spaceName
{
    HackerSpaceInfo * hs=[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HackerSpaceInfo class])  inManagedObjectContext:self.coreDataContext];
    hs.spaceName=spaceName;
    
    return hs;
}

-(NSArray *)allSpacesWithName:(NSString *)spaceName
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([HackerSpaceInfo class]) inManagedObjectContext:self.coreDataContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptorByTitle = [[NSSortDescriptor alloc] initWithKey:@"spaceName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByTitle,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    if(spaceName)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spaceName == %@", spaceName];
        [fetchRequest setPredicate:predicate];
    }
    
    
    return [self.coreDataContext executeFetchRequest:fetchRequest error:nil];
}
-(HackerSpaceInfo *) spaceInfoForName:(NSString *)spaceName
{

    NSArray * hackerSpaces = [self allSpacesWithName:spaceName];
    
    if([hackerSpaces count]==0)
    {
        return nil;
    }
    else
    {
         //nunca debe haber 2 HS con el mismo nombre
        HackerSpaceInfo * hackerSpace=[hackerSpaces objectAtIndex: 0];
        return hackerSpace;
    }
    
}
-(HackerSpaceInfo *)preparedSpaceForUpdateWithName:(NSString *)spaceName
{
    HackerSpaceInfo * hackerSpace=[self spaceInfoForName:spaceName];
    
    if(hackerSpace==nil)
    {
       return [self createHackerSpaceWithName:spaceName];
    }else{
        for(Event * event in hackerSpace.events)
        {
            //borrar imagen si existe
            [self.coreDataContext deleteObject:event];
        }
        
        for(Contact * contact in hackerSpace.contacts)
        {
            //borrar imagen si existe
            [self.coreDataContext deleteObject:contact];
        }

        NSString * folderPath=[DOCUMENTS_FOLDER stringByAppendingPathComponent:hackerSpace.spaceName];
        [self eraseFileFromDisk:folderPath];
        return hackerSpace;
    }

}
-(NSString *)contactTypeNameForType:(NSString *)type
{
    if([type isEqualToString:@"ml"])
        return @"Mailing list";
    else if( [type isEqualToString:@"phone"])
        return @"Telephone";
    else if( [type isEqualToString:@"sip"])
        return @"Sip uri";
    else if( [type isEqualToString:@"irc"])
        return @"IRC";
    else if( [type isEqualToString:@"twitter"])
        return @"Twitter";
    else if( [type isEqualToString:@"email"])
        return @"E-Mail";
    else if( [type isEqualToString:@"jabber"])
        return @"Jabber";
    else if( [type isEqualToString:@"keymaster"])
        return @"Key Master";
    else
        return type;
    
}
-(void)updateSpacesListWithDictionary:(NSDictionary *)dictionary
{
    NSArray * spaceNames=[dictionary allKeys];
    spaceNames=[spaceNames sortedArrayUsingSelector:@selector(compare:)];
    NSArray * spaces=[self allSpacesWithName:nil];//if name is nil retrieve all the available spaces
    //se ordena todo alfabeticamente
    NSMutableArray * spacesToCreate=[[NSMutableArray alloc] init];
    NSMutableArray * spacesToDelete=[[NSMutableArray alloc] init];
    
    NSInteger nextSpaceIndex=0;
    
    for(NSString *spaceName in spaceNames)
    {
        NSMutableArray * candidatesToDelete=[[NSMutableArray alloc] init];
        BOOL existSpace=NO;
        for(NSInteger i=nextSpaceIndex; i<[spaces count];i++)
        {
            HackerSpaceInfo * hs=[spaces objectAtIndex:i];
            if([hs.spaceName isEqualToString:spaceName])
            {
                nextSpaceIndex=i+1;
                existSpace=YES;
                [spacesToDelete addObjectsFromArray:candidatesToDelete];
                break;
            }else
            {
                [candidatesToDelete addObject:hs];
            }
        }
        [candidatesToDelete removeAllObjects];
        if(!existSpace)
            [spacesToCreate addObject:spaceName];
    
    }
    
    for(NSString *spaceKey in spacesToCreate)
    {
        NSString *spaceURL=[dictionary valueForKey:spaceKey];
        HackerSpaceInfo * createdHS=[self createHackerSpaceWithName:spaceKey];
        createdHS.url_status=spaceURL;
    }
    [spacesToCreate removeAllObjects];
    
    for(HackerSpaceInfo *spaceToDelete in spacesToDelete)
    {
        [self.coreDataContext deleteObject:spaceToDelete];
    }
    [spacesToDelete removeAllObjects];
    [self save];
    [self setInUpdateState:NO];
}
-(void)updateCurrentSpaceWithData:(NSDictionary *)dictionary
{
    NSLog(@"Mi diccionario %@",dictionary);
    NSString *spaceName=[dictionary valueForKey:@"space"];
    [Configuration setCurrentSpaceName:spaceName];
    HackerSpaceInfo * spaceInfo=[self preparedSpaceForUpdateWithName:spaceName];
    spaceInfo.url=[dictionary valueForKey:@"url"];
    spaceInfo.address=[dictionary valueForKey:@"address"];
    spaceInfo.iconURL=[dictionary valueForKey:@"logo"];
    spaceInfo.iconPath=[self createImageFilePathForSpaceName:spaceName];
    spaceInfo.lastchange=[[dictionary valueForKey:@"lastchange"] integerValue];
    spaceInfo.lat=[[dictionary valueForKey:@"lon"] floatValue];
    spaceInfo.lon= [[dictionary valueForKey:@"lat"] floatValue];
    spaceInfo.open=[[dictionary valueForKey:@"open"] boolValue];
    spaceInfo.status=[dictionary valueForKey:@"status"];
    NSDictionary * stateIconsDictioanry=[dictionary objectForKey:@"icon"];
    
    spaceInfo.closedIconURL=[stateIconsDictioanry valueForKey:@"closed"];
    spaceInfo.closedIconPath=[self createImageFilePathForSpaceName:spaceName];
    spaceInfo.openIconURL=[stateIconsDictioanry valueForKey:@"open"];
    spaceInfo.openIconPath=[self createImageFilePathForSpaceName:spaceName];

    NSDictionary * contactDictionary=[dictionary objectForKey:@"contact"];
    NSArray * contactKeys=[contactDictionary allKeys];
    if(contactKeys!=0)
        for(NSString * key in contactKeys)
        {
            
            NSString * contactType=[self contactTypeNameForType:key];
            Contact * contact =[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Contact class]) inManagedObjectContext:self.coreDataContext];
            if([[contactDictionary valueForKey:key] isKindOfClass:[NSArray class]])
            {
                NSArray *items =[contactDictionary valueForKey:key];
                NSString * concatenatedItems=@"";
                for(NSInteger i=0;i<[items count];i++)
                {
                    NSString * item=[items objectAtIndex:i];
                    NSString *separator=@"";
                    if(i<([items count]-1))
                        separator=@",\n";
                    concatenatedItems=[concatenatedItems stringByAppendingFormat:@"%@%@",item,separator];
                }
                contact.contactData=concatenatedItems;
            }
            else
                contact.contactData=[contactDictionary valueForKey:key];
            contact.contactType=contactType;
            contact.hackerspace=spaceInfo;
        }
    
    NSArray * events=[dictionary objectForKey:@"events"];
    if(events!=nil)
        for(NSDictionary * eventDictionary  in events)
        {

            Event * event=[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Event class]) inManagedObjectContext:self.coreDataContext];
            
            BOOL checkEvent=([[eventDictionary valueForKey:@"type"] isEqualToString:@"check-in"]||[[eventDictionary valueForKey:@"type"] isEqualToString:@"check-out"]);
            event.checkEvent=checkEvent;
            event.attendant=[eventDictionary valueForKey:@"name"];
            event.time=[[eventDictionary valueForKey:@"t"] integerValue];
            event.extra=[eventDictionary valueForKey:@"extra"];
            NSString *urlImage=[eventDictionary valueForKey:@"image"];
            if(urlImage)
            {
                event.imageURL=[eventDictionary valueForKey:@"image"];
                event.imagePath=[self createImageFilePathForSpaceName:spaceName];
            }
            
            if(checkEvent)
            {
                NSString * type=([[eventDictionary valueForKey:@"type"] isEqualToString:@"check-in"])?@"Check-in: ":@"Check-out: ";
                event.name=[type stringByAppendingString:event.attendant];
                

            }else
            {
                event.name=[eventDictionary valueForKey:@"name"];
                event.start=[[eventDictionary valueForKey:@"start"] integerValue];
                event.end=[[eventDictionary valueForKey:@"end"] integerValue];
                

            }
            event.hackerSpace=spaceInfo;
            
        }
    
    [self save];
    
    [self notifyUpdateWithSpace:spaceInfo];
    [self activateLoadingNotifier:NO];
    [self setInUpdateState:NO];
    [self.coreDataContext refreshObject:spaceInfo mergeChanges:NO];
}

-(NSString *)createImageFilePathForSpaceName:(NSString *)spaceName
{
    NSString * folderPath=[DOCUMENTS_FOLDER stringByAppendingPathComponent:spaceName];
    [self createFolderIfNeccesary:folderPath];
    NSString * fileName=[NSString stringWithFormat:@"%f%d.png",[NSDate timeIntervalSinceReferenceDate],(arc4random() % 1000)];
    NSString * fullPath=[folderPath stringByAppendingPathComponent:fileName];
    return fullPath;
    
}
-(void)createFolderIfNeccesary:(NSString *)folderPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL success;
    if (![fm fileExistsAtPath:folderPath])
    {
        success=[fm createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
        if(!success)
            NSLog(@"[ERROR]:Ocurrio un error al escribir el folder %@",folderPath);
    }
}
-(void)save
{
    //Save all operations
    NSError *error = nil;
    if (![self.coreDataContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(void)notifyUpdateWithSpace:(HackerSpaceInfo *)space
{
    NSManagedObjectID * coreDataID=space.objectID;
    NSString * spaceName=space.spaceName;
    
    NSDictionary * userInfo=[NSDictionary dictionaryWithObjectsAndKeys:coreDataID,USRINFO_CDOBJID_KEY,
                             spaceName,USRINFO_SPACE_KEY, nil];
    
    NSNotification *notification = [NSNotification notificationWithName:SPACE_UPDATE_NOTIFICATION_NAME
                                                                 object:self userInfo:userInfo];
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotification:notification];
}

-(void)notifySpaceListUpdate
{

    NSNotification *notification = [NSNotification notificationWithName:SPACELIST_UPDATE_NOTIFICATION_NAME
                                                                 object:self userInfo:nil];
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotification:notification];
}
-(void)activateLoadingNotifier:(BOOL)activate
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:activate];
}

#pragma mark -File System Methods
-(void)eraseFileFromDisk:(NSString *)path{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    if([fm fileExistsAtPath:path])
        if(![fm removeItemAtPath:path error:&error])
            NSLog(@"[ERROR]:Ocurrio un error al borrar el archivo o carpeta %@",path);
}

-(void)saveImageToDisk:(UIImage *)assignedImage withPath:(NSString *)path
{
    NSData * data=UIImagePNGRepresentation(assignedImage);
    [self saveIDataToDisk:data withPath:path];
    
    
}
-(void)saveIDataToDisk:(NSData *)data withPath:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL success=NO;
    if([fm fileExistsAtPath:path])
    {
        success=[fm removeItemAtPath:path error:&error];
        if (!success || error)
        {
            NSLog(@"[ERROR]:Ocurrio un error al sobreescribir el archivo %@",path);
            return;
        }
    }
    success=[fm createFileAtPath:path contents:data attributes:nil];
    if(!success)
        NSLog(@"[ERROR]:Ocurrio un error al escribir el archivo %@",path);
    
}

#pragma mark - Download Operations 
-(void)addDownloadItemRequest:(DownloadRequest *)request
{
    if(request.tag!=0)
    {
        for(DownloadRequest *currentRequest in networkDownloadQueue.operations)
        {
            if(currentRequest.tag==request.tag)
            {
                currentRequest.downloadObserver=request.downloadObserver;
                currentRequest.finishObserverSelector=request.finishObserverSelector;
                currentRequest.failObserverSelector=request.failObserverSelector;
                currentRequest.cancelObserverSelector=request.cancelObserverSelector;
                return;
            }
        }
    }
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(downloadIsFinished:)];
    [request setDidFailSelector:@selector(downloadFailed:)];
    
    [networkDownloadQueue addOperation:request];
    [networkDownloadQueue go];
    
}
-(void)removeDownloadObserver:(id)observer
{
    if(observer)
    for(DownloadRequest *currentRequest in networkDownloadQueue.operations)
    {
        if(currentRequest.downloadObserver==observer)
        {
            currentRequest.downloadObserver=nil;
            currentRequest.finishObserverSelector=nil;
            currentRequest.failObserverSelector=nil;
            currentRequest.cancelObserverSelector=nil;
        }
    }
}
-(void)downloadIsFinished:(DownloadRequest *)request
{
    if(request.downloadObserver&&[request.downloadObserver respondsToSelector: request.finishObserverSelector])
    {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [request.downloadObserver performSelector:request.finishObserverSelector withObject:request];
        #pragma clang diagnostic pop
    }
    
}
-(void)downloadFailed:(DownloadRequest *)request
{
    if(request.downloadObserver&&[request.downloadObserver respondsToSelector: request.failObserverSelector])
    {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [request.downloadObserver performSelector:request.failObserverSelector withObject:request];
        #pragma clang diagnostic pop
    }
    
}

@end
