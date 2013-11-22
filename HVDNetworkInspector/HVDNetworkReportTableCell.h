//
//  HVDNetworkReportTableCell.h
//
//  Created by Harshad on 22/11/13.
//  Copyright (c) 2013 9Slides. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat const HVDNetworkReportTableCellHeight;

@class HVDNetworkConnectionLog;

@interface HVDNetworkReportTableCell : UITableViewCell

- (void)setLog:(HVDNetworkConnectionLog *)log;

@end
