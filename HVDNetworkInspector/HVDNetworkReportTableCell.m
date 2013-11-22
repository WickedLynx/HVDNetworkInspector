//
//  HVDNetworkReportTableCell.m
//
//  Created by Harshad on 22/11/13.
//  Copyright (c) 2013 9Slides. All rights reserved.
//

#import "HVDNetworkReportTableCell.h"
#import "HVDNetworkConnectionLog.h"

CGFloat const HVDNetworkReportTableCellHeight = 80.0f;

@implementation HVDNetworkReportTableCell {
    __weak UILabel *_topLabel;
    __weak UILabel *_bottomLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.bounds.size.width - 10, 50)];
        [topLabel setAdjustsFontSizeToFitWidth:YES];
        [topLabel setNumberOfLines:3];
        [topLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [topLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [topLabel setText:@""];
        [self addSubview:topLabel];
        [topLabel setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth)];
        _topLabel = topLabel;

        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 55, self.bounds.size.width - 10, 20)];
        [bottomLabel setAdjustsFontSizeToFitWidth:YES];
        [bottomLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [bottomLabel setText:@""];
        [bottomLabel setTextColor:[UIColor darkGrayColor]];
        [self addSubview:bottomLabel];
        [bottomLabel setAutoresizingMask:_topLabel.autoresizingMask];
        _bottomLabel = bottomLabel;
    }
    return self;
}


- (void)setLog:(HVDNetworkConnectionLog *)log {
    [_topLabel setText:[[[log request] URL] absoluteString]];

    NSString *detailText = [NSString stringWithFormat:@"Time: %.4f  Type: %@  Bytes: %lld", [log loadTime], [[log request] HTTPMethod], [log fetchedDataLength]];
    [_bottomLabel setText:detailText];

    switch (log.state) {
        case HVDNetworkConnectionLogStateStarted:
            [_topLabel setTextColor:[UIColor colorWithRed:0.00f green:0.49f blue:0.90f alpha:1.00f]];
            break;

        case HVDNetworkConnectionLogStateCompleted:
            [_topLabel setTextColor:[UIColor colorWithRed:0.00f green:0.46f blue:0.00f alpha:1.00f]];
            break;

        case HVDNetworkConnectionLogStateFailed:
            [_topLabel setTextColor:[UIColor colorWithRed:0.90f green:0.05f blue:0.00f alpha:1.00f]];
            break;

        default:
            break;
    }

}
@end
