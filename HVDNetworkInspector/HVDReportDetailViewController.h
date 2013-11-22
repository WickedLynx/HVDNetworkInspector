//
//  HVDReportDetailViewController.h
//
//  Created by Harshad on 21/11/2013.
//  Copyright (c) 2013 9Slides. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HVDNetworkConnectionLog;

@interface HVDReportDetailViewController : UIViewController

- (instancetype)initWithConnectionLog:(HVDNetworkConnectionLog *)log;

@end
