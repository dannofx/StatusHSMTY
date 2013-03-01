//
//  DetailedEventViewController.m
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "DetailedEventViewController.h"
#import "ContentManager.h"
#import "DownloadRequest.h"
#import "NSDate+HSMTYFormats.h"

@interface DetailedEventViewController ()

-(void)imageDownloadFinishedSuccessfully:(DownloadRequest *)request;
-(void)imageDownloadFailed:(DownloadRequest *)request;
-(void)setImageViewInLoadingState:(BOOL)loadingState;
@end

@implementation DetailedEventViewController
@synthesize event;
@synthesize name_label;
@synthesize dateInit_label;
@synthesize description_label;
@synthesize imageView;
@synthesize imageActivityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self setImageViewInLoadingState:NO];

    self.name_label.text=self.event.name;
    if(self.event.checkEvent)
    {
        NSString * dateString=(self.event.time>0)?[self.event.timeDate stringDateWithCompleteFormat]:NSLocalizedString(@"Date no available" ,@"Fecha no disponible");
        self.dateInit_label.text=[NSLocalizedString(@"Since:", @"Since:") stringByAppendingString:dateString];
    
    }
    else
    {
        NSString *completeText;
        NSString * initText=[NSLocalizedString(@"Start:", @"Start:") stringByAppendingString:[self.event.startDate stringDateWithCompleteFormat]];
        NSString * finalText=[NSLocalizedString(@"End:", @"End:") stringByAppendingString:[self.event.endDate stringDateWithCompleteFormat]];
        completeText=[NSString stringWithFormat:@"%@\n%@",initText,finalText];
        self.dateInit_label.text=completeText;
    }

    if(self.event.extra)
        self.description_label.text=self.event.extra;
    else
        self.description_label.text=NSLocalizedString(@"Description no available", @"Description no available");
    
    UIImage * image=event.image;
    if(image==nil)
    {
        if(event.imageURL!=nil)
        {
            ContentManager * contentManager=[ContentManager contentManager];
            DownloadRequest * request=[DownloadRequest requestForFileAt:event.imageURL savingOn:event.imagePath];
            request.downloadObserver=self;
            request.tag=0;
            request.finishObserverSelector=@selector(imageDownloadFinishedSuccessfully:);
            request.failObserverSelector=@selector(imageDownloadFailed:);
            [contentManager addDownloadItemRequest:request];
             [self setImageViewInLoadingState:YES];
        }else{
           self.imageView.image=[UIImage imageNamed:@"generic.png"];
        }
    }else{
        self.imageView.image=image;
    }
	
}

-(void)imageDownloadFinishedSuccessfully:(DownloadRequest *)request
{
    [self setImageViewInLoadingState:NO];
    self.imageView.image=self.event.image;

}

-(void)imageDownloadFailed:(DownloadRequest *)request
{
    [self setImageViewInLoadingState:NO];
    //TODO: Default image
}

-(void)setImageViewInLoadingState:(BOOL)loadingState
{
    self.imageView.hidden=loadingState;
    if(loadingState)
        [self.imageActivityIndicator startAnimating];
    else
        [self.imageActivityIndicator stopAnimating];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
