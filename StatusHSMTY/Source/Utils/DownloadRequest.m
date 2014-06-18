//
//  MePaparazzoDownloadRequest.m
//  MePaparazzo
//
//  Created by Danno on 11/22/12.
//  Copyright (c) 2012 Danno. All rights reserved.
//

#import "DownloadRequest.h"
@interface DownloadRequest()
@end

@implementation DownloadRequest
@synthesize downloadObserver;
@synthesize finishObserverSelector;
@synthesize failObserverSelector;
@synthesize cancelObserverSelector;


+(DownloadRequest *)requestForFileAt:(NSString *)urlString savingOn:(NSString *)localPath{
    
    NSURL *url = [NSURL URLWithString:urlString];
    DownloadRequest *request = [self requestWithURL:url];
    [request setDownloadDestinationPath:localPath];
    return request;
}


@end
