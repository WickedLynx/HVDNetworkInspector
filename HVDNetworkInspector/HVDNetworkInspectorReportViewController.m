//
//  HVDNetworkInspectorReportViewController.m
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import "HVDNetworkInspectorReportViewController.h"
#import "HVDNetworkConnectionLog.h"
#import "HVDNetworkReportDetailViewController.h"
#import "HVDNetworkReportTableCell.h"

@interface HVDNetworkInspectorReportViewController () <UITableViewDataSource, UITableViewDelegate>

- (void)touchDone;
@property (weak, nonatomic) UITableView *reportTableView;

@end

@implementation HVDNetworkInspectorReportViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self setTitle:@"Network Report"];

    UITableView *aTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [aTableView setDataSource:self];
    [aTableView setDelegate:self];
    [aTableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [aTableView setRowHeight:HVDNetworkReportTableCellHeight];

    [self.view addSubview:aTableView];

    [self setReportTableView:aTableView];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(touchDone)];
    [self.navigationItem setRightBarButtonItem:doneButton];

    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:nil];
    [self.navigationItem setLeftBarButtonItem:clearButton];

}

- (void)refresh {
    NSMutableArray *array = [self.metrics mutableCopy];
    NSSortDescriptor *sortByLoadTime = [NSSortDescriptor sortDescriptorWithKey:@"loadTime" ascending:NO];
    [array sortUsingDescriptors:@[sortByLoadTime]];
    [self setMetrics:array];

    [self.reportTableView reloadData];
}

- (void)touchDone {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.metrics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *HVDNetworkInspectorReportTableCell = @"HVDNetworkInspectorReportTableCell";

    HVDNetworkReportTableCell *cell = [tableView dequeueReusableCellWithIdentifier:HVDNetworkInspectorReportTableCell];

    if (!cell) {
        cell = [[HVDNetworkReportTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HVDNetworkInspectorReportTableCell];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }

    HVDNetworkConnectionLog *metric = self.metrics[indexPath.row];
    [cell setLog:metric];

    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HVDNetworkConnectionLog *log = _metrics[indexPath.row];
    
    HVDNetworkReportDetailViewController *detailViewcontroller = [[HVDNetworkReportDetailViewController alloc] initWithConnectionLog:log];
    
    [self.navigationController pushViewController:detailViewcontroller animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
