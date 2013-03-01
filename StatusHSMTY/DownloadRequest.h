//
//  MePaparazzoDownloadRequest.h
//  MePaparazzo
//
//  Created by Danno on 11/22/12.
//  Copyright (c) 2012 Danno. All rights reserved.
//

#import "ASIHTTPRequest.h"

@interface DownloadRequest : ASIHTTPRequest //ASIFormDataRequest

@property(nonatomic,weak) id downloadObserver;
@property(assign)SEL finishObserverSelector;
@property(assign)SEL failObserverSelector;
@property(assign)SEL cancelObserverSelector;


+(DownloadRequest *)requestForFileAt:(NSString *)urlString savingOn:(NSString *)localPath;

@end
