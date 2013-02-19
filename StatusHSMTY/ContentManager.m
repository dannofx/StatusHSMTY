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
#import "AppDelegate.h"

#import "Contact.h"
#import "Event.h"

@interface ContentManager()

    @property (nonatomic,assign) NSManagedObjectContext * coreDataContext;
    -(void)contentDownloadedSuccessfully:(ASIHTTPRequest *) request;
    -(void)contentDownloadFailed:(ASIHTTPRequest *) request;
    -(void)updateContentWithData:(NSDictionary *)dictionary;
    -(void)activateLoadingNotifier:(BOOL)activate;
    + (id)hiddenAlloc;
@end
@implementation ContentManager
@synthesize coreDataContext=_coreDataContext;
NSString *const signatureEntityName = @"Signature";

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
    NSLog(@"%@: use +sharedInstance instead of +alloc", [[self class] description]);
    return nil;
}
+ (id)new {
    return [self alloc];
}
+ (id)allocWithZone:(NSZone *)zone {
    return [self alloc];
}
- (id)copyWithZone:(NSZone *)zone
{ // -copy inherited from NSObject calls -copyWithZone:
    NSLog(@"Contentmanagerr: attempt to -copy may be a bug."); [self retain];
    return self;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
    
    return [self copyWithZone:zone];
}
+ (ContentManager *)contentManager {
    static ContentManager *unicInstance = nil;
    if (!unicInstance)
    {

        unicInstance = [[self hiddenAlloc] init];
    }
    return unicInstance;
    
}

#pragma mark - User methods
-(void)launchContentUpdate
{
    [self launchContentUpdateWithURL:HSMTY_URL];

}
-(void)launchContentUpdateWithURL:(NSString *)hackersURL
{
    [self activateLoadingNotifier:YES];
    NSURL *url = [NSURL URLWithString:hackersURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:TIMEOUT_HIGH_PRIORITY];
    [request setDidFinishSelector:@selector(contentDownloadedSuccessfully:)];
    [request setDidFailSelector:@selector(contentDownloadFailed:)];
    [request setDelegate:self];
    [request startAsynchronous];
}
-(void)eraseContent
{

}
-(void)eraseContentFor:(HackerSpaceInfo *)hackerSpace
{}



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
    [self updateContentWithData:jsonDictionary];


}
-(void)contentDownloadFailed:(ASIHTTPRequest *) request
{
#warning launchError
    [self activateLoadingNotifier:NO];
}

-(HackerSpaceInfo *)createHackerSpaceWithName:(NSString *)spaceName
{
    HackerSpaceInfo * hs=[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HackerSpaceInfo class])  inManagedObjectContext:self.coreDataContext];
    hs.spaceName=spaceName;
    
    return hs;
}

-(HackerSpaceInfo *) spaceInfoForName:(NSString *)spaceName
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([HackerSpaceInfo class]) inManagedObjectContext:self.coreDataContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spaceName == %@", spaceName];
    NSSortDescriptor *sortDescriptorByTitle = [[NSSortDescriptor alloc] initWithKey:@"spaceName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByTitle,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
    
    
    NSArray * hackerSpaces = [self.coreDataContext executeFetchRequest:fetchRequest error:nil];
    
    if([hackerSpaces count]==0)
    {
        return [self createHackerSpaceWithName:spaceName];
    }
    else
    {
         //nunca debe haber 2 HS con el mismo nombre
        HackerSpaceInfo * hackerSpace=[hackerSpaces objectAtIndex: 0];
        

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
    else
        return type;
    
}
-(void)updateContentWithData:(NSDictionary *)dictionary
{
    NSString *spaceName=[dictionary valueForKey:@"space"];

    HackerSpaceInfo * spaceInfo=[self spaceInfoForName:spaceName];
    spaceInfo.url=[dictionary valueForKey:@"url"];
    spaceInfo.address=[dictionary valueForKey:@"address"];
    spaceInfo.iconURL=[dictionary valueForKey:@"logo"];
    spaceInfo.iconPath=[self createImageFilePathForSpaceName:spaceName];
    spaceInfo.lastchange=[[dictionary valueForKey:@"lastchange"] integerValue];
    spaceInfo.lat=[[dictionary valueForKey:@"lon"] floatValue];
    spaceInfo.lon= [[dictionary valueForKey:@"lat"] floatValue];
    spaceInfo.open=[[dictionary valueForKey:@"open"] boolValue];
    NSDictionary * stateIconsDictioanry=[dictionary objectForKey:@"icon"];
    
    spaceInfo.closedIconURL=[stateIconsDictioanry valueForKey:@"closed"];
    spaceInfo.closedIconPath=[self createImageFilePathForSpaceName:spaceName];
    spaceInfo.openIconURL=[stateIconsDictioanry valueForKey:@"open"];
    spaceInfo.openIconPath=[self createHackerSpaceWithName:spaceName];

    NSDictionary * contactDictionary=[dictionary objectForKey:@"contact"];
    NSArray * contactKeys=[contactDictionary allKeys];
    if(contactKeys!=0)
        for(NSString * key in contactKeys)
        {
            NSString * contactData=[contactDictionary valueForKey:key];
            NSString * contactType=[self contactTypeNameForType:key];
            Contact * contact =[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Contact class]) inManagedObjectContext:self.coreDataContext];
            contact.contactData=contactData;
            contact.contactType=contactType;
            contact.hackerspace=spaceInfo;
        }
    
    NSArray * events=[dictionary objectForKey:@"events"];
    if(events!=nil)
        for(NSDictionary * eventDictionary  in events)
        {
            Event * event=[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Event class]) inManagedObjectContext:self.coreDataContext];
            event.attendant=[eventDictionary valueForKey:@"name"];
            event.name=@"No available";
            event.initDate=[[eventDictionary valueForKey:@"t"] integerValue];
            event.hackerSpace=spaceInfo;
            
        }
    
    [self save];
    
    [self notifyUpdateWithSpace:spaceName];
    
    [self activateLoadingNotifier:NO];
    //si existe le borra todos los datos
    //si no existe lo crea
}

-(NSString *)createImageFilePathForSpaceName:(NSString *)spaceName
{
    NSString * folderPath=spaceName;
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

-(void)notifyUpdateWithSpace:(NSString *)spaceName
{
    NSNotification *notification = [NSNotification notificationWithName:SPACE_UPDATE_NOTIFICATION_NAME object:self userInfo:nil];
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotification:notification];
}
-(void)activateLoadingNotifier:(BOOL)activate
{
    //pone el iconito de carga, asi bien chido
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

@end
