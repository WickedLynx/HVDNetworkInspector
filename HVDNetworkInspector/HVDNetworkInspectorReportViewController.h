//
//  HVDNetworkInspectorReportViewController.h
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HVDNetworkInspectorReportViewController : UIViewController

@property (copy, nonatomic) NSArray *metrics;

- (void)refresh;

@end
