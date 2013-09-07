//
//  PAMasterViewController.m
//  UIKitStuff
//
//  Created by Andrew Aude on 9/7/13.
//  Copyright (c) 2013 Andrew Aude. All rights reserved.
//

#import "PAMasterViewController.h"
#import <PAAdminClient/PAAdminClient.h>
#import "PADetailViewController.h"

@interface PAMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation PAMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    [PAAdminClient sharedAdminClient];
}

- (void)pressedBarButton:(id)sender {
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *go = [[UIBarButtonItem alloc] initWithTitle:@"Go" style:UIBarButtonItemStylePlain target:self action:@selector(pressedBarButton:)];
    go.width = 200;

    self.toolbarItems = @[go];
    [self.navigationController setToolbarHidden:NO];
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
