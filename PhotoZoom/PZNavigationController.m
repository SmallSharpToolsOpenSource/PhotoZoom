//
//  PZNavigationController.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 11/15/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZNavigationController.h"

@interface PZNavigationController ()

@end

@implementation PZNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setupNavigationController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupNavigationController];
}

- (void)setupNavigationController {
    // Why does the navigation bar not show by default? Why can't I make it translucent from IB?
//    DebugLog(@"setupNavigationController");
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:TRUE];
    
//        self.toolbar.translucent = TRUE;
//        self.toolbar.tintColor = [UIColor grayColor];
//        self.navigationBar.translucent = TRUE;
//        self.navigationBar.tintColor = [UIColor grayColor];
        
//        self.navigationController.navigationBar.hidden = FALSE;
//        self.navigationController.toolbar.hidden = FALSE;
//        [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
//        [self.navigationController setToolbarHidden:FALSE animated:TRUE];
//    });
}

@end
