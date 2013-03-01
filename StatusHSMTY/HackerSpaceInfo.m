//
//  HackerSpaceInfo.m
//  StatusHSMTY
//
//  Created by Danno on 2/26/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "HackerSpaceInfo.h"
#import "Contact.h"
#import "Event.h"
#import "ContentManager.h"


@implementation HackerSpaceInfo

@dynamic address;
@dynamic closedIconPath;
@dynamic closedIconURL;
@dynamic iconPath;
@dynamic iconURL;
@dynamic lastchange;
@dynamic lat;
@dynamic lon;
@dynamic open;
@dynamic openIconPath;
@dynamic openIconURL;
@dynamic spaceName;
@dynamic url;
@dynamic status;
@dynamic contacts;
@dynamic events;
@synthesize lastChangeDate;
@synthesize openImage;
@synthesize closeImage;
@synthesize iconImage;


-(NSDate *)lastChangeDate
{
    return [NSDate dateWithTimeIntervalSince1970:self.lastchange];
    
}


-(UIImage *)openImage{
    
    return [self imageForPath:self.openIconPath];
}
-(UIImage *)closeImage{
    
    return [self imageForPath:self.closedIconPath];
}
-(UIImage *)iconImage{
    
    return [self imageForPath:self.iconPath];
}

-(void)setIconImage:(UIImage *)image
{
    [self setImage:image onPath:self.iconPath];
    
}
-(void)setOpenImage:(UIImage *)image
{
    [self setImage:image onPath:self.openIconPath];
    
}
-(void)setCloseImage:(UIImage *)image
{
    [self setImage:image onPath:self.closedIconPath];
    
}
-(UIImage *)imageForPath:(NSString *)imagePath{
    
    if(imagePath==nil)
        return nil;
    
    return [UIImage imageWithContentsOfFile:imagePath];
    
    
}

-(void)setImage:(UIImage *)image onPath:(NSString *)imagePath
{
    if(imagePath==nil)
    {
        
        NSLog(@"[ERROR]: Necesita asignar una direccion en disco a la imagen antes de asignar una. utilice createLocalPathWithFolder:");
        return;
    }
    if(image!=nil)
        [[ContentManager contentManager] saveImageToDisk:image withPath:imagePath];
    else
        [[ContentManager contentManager] eraseFileFromDisk:imagePath];
}




@end
