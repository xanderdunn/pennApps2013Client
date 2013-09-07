//
//  PADetailViewController.h
//  UIKitStuff
//
//  Created by Andrew Aude on 9/7/13.
//  Copyright (c) 2013 Andrew Aude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PADetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
