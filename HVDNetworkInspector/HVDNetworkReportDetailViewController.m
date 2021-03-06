//
//  HVDReportDetailViewController.m
//
//  Created by Harshad on 21/11/2013.
//  Copyright (c) 2013 9Slides. All rights reserved.
//

#import "HVDNetworkReportDetailViewController.h"
#import "HVDNetworkConnectionLog.h"

@interface HVDNetworkReportDetailViewController () {
    HVDNetworkConnectionLog *_log;
    __weak UITextView *_reportTextView;
}

@end

@implementation HVDNetworkReportDetailViewController

- (instancetype)initWithConnectionLog:(HVDNetworkConnectionLog *)log {
    
    self = [super init];
    
    if (self != nil) {
        
        _log = log;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setTitle:@"Report Detail"];
    
    UITextView *reportTextView = nil;

    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"6"]) {
        reportTextView = [[UITextView alloc] initWithFrame:self.view.bounds];
    } else {
        reportTextView = [[UITextView alloc] initWithFrame:self.view.bounds textContainer:nil];
    }

    [reportTextView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [reportTextView setText:[_log formattedReport]];
    [self.view addSubview:reportTextView];
    
    _reportTextView = reportTextView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _log = nil;
}

@end
