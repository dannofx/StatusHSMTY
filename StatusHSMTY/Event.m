//
//  Event.m
//  StatusHSMTY
//
//  Created by Danno on 2/26/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "Event.h"
#import "HackerSpaceInfo.h"
#import "ContentManager.h"


@implementation Event

@dynamic attendant;
@dynamic start;
@dynamic end;
@dynamic time;
@dynamic name;
@dynamic extra;
@dynamic checkEvent;
@dynamic hackerSpace;
@dynamic startDate;
@dynamic endDate;
@dynamic timeDate;
@dynamic imagePath;
@dynamic imageURL;
@dynamic image;


-(NSDate *)startDate
{
    return [NSDate dateWithTimeIntervalSince1970:self.start];
    
}
-(NSDate *)endDate
{
    return [NSDate dateWithTimeIntervalSince1970:self.end];
    
}

-(NSDate *)timeDate
{
    if(self.time<=0)
        return nil;
    else
        return [NSDate dateWithTimeIntervalSince1970:self.time];
}


-(UIImage *)image{
    
    if(self.imagePath==nil)
        return nil;
    
    return [UIImage imageWithContentsOfFile:self.imagePath];
    
    
}

-(void)setImage:(UIImage *)image
{
    if(self.imagePath==nil)
    {
        
        NSLog(@"[ERROR]: Necesita asignar una direccion en disco a la imagen antes de asignar una. utilice createLocalPathWithFolder:");
        return;
    }
    if(image!=nil)
        [[ContentManager contentManager] saveImageToDisk:image withPath:self.imagePath];
    else
        [[ContentManager contentManager] eraseFileFromDisk:self.imagePath];
}
/*
-(NSString *)humanTime
{
    NSString * timeString=@"";
    NSInteger remainingTime=self.time;
    NSInteger days=remainingTime/(60*60*24);
    remainingTime=remainingTime%(60*60*24);
    NSInteger hours=remainingTime/(60*60);
    remainingTime=remainingTime%(60*60);
    NSInteger minutes=remainingTime/60;
    remainingTime=remainingTime%60;
    NSInteger seconds=remainingTime;
    
    if(days!=0)
    {
        timeString=[timeString stringByAppendingFormat:@"%d %@",days,NSLocalizedString(@"days",@"days")];
    }
    if(hours!=0)
    {
        timeString=[timeString stringByAppendingFormat:@"%d %@",hours,NSLocalizedString(@"hours",@"hours")];
    }
    if(minutes!=0)
    {
        timeString=[timeString stringByAppendingFormat:@"%d %@",minutes,NSLocalizedString(@"minutes",@"minutes")];
    }
    if(seconds>0)
    {
        timeString=[timeString stringByAppendingFormat:@"%d %@",seconds,NSLocalizedString(@"seconds",@"seconds")];
    }
    else
    {
        timeString=[timeString stringByAppendingFormat:@"0 %@",NSLocalizedString(@"seconds",@"seconds")];
    }
    
    return timeString;
}*/

@end
