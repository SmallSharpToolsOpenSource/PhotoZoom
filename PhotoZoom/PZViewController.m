//
//  PZViewController.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZViewController.h"

#import "PZPhotoView.h"

@interface PZViewController () <PZPhotoViewDelegate>

@property (readonly) NSArray *customToolbarItems;

@end

@implementation PZViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    DebugLog(@"viewDidLoad");
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([self.view isKindOfClass:[PZPhotoView class]]) {
        PZPhotoView *photoView = (PZPhotoView *)self.view;
        photoView.photoViewDelegate = self;
        [photoView displayImage:[UIImage imageNamed:@"Box.png"]];
    }
    
    self.navigationController.toolbar.translucent = TRUE;
    self.navigationController.toolbar.tintColor = [UIColor grayColor];
    [self setToolbarItems:self.customToolbarItems animated:FALSE];
    [self.navigationController setToolbarHidden:FALSE];
}

- (NSArray *)customToolbarItems {
    UIBarButtonItem *flexItem1 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                   target:self
                                   action:nil];
    UIBarButtonItem *flexItem2 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                   target:self
                                  action:nil];
    UIBarButtonItem *flexItem3 = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                  target:self
                                  action:nil];
    UIBarButtonItem *flexItem4 = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                  target:self
                                  action:nil];
    
    UIBarButtonItem *maximumButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Maxium"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                   action:@selector(showMaximumSize:)];
    
    UIBarButtonItem *mediumButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Medium"
                                  style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:@selector(showMediumSize:)];
    
    UIBarButtonItem *minimumButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Minimum"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                  action:@selector(showMinimumSize:)];
    
    return @[flexItem1, maximumButton, flexItem2, mediumButton, flexItem3, minimumButton, flexItem4];
}

- (void)showMaximumSize:(id)sender {
    DebugLog(@"showMaximumSize");
    
    if ([self.view isKindOfClass:[PZPhotoView class]]) {
        PZPhotoView *photoView = (PZPhotoView *)self.view;
        [photoView updateZoomScale:photoView.maximumZoomScale];
    }
}

- (void)showMediumSize:(id)sender {
    DebugLog(@"showMediumSize");
    
    if ([self.view isKindOfClass:[PZPhotoView class]]) {
        PZPhotoView *photoView = (PZPhotoView *)self.view;
        float newScale = (photoView.minimumZoomScale + photoView.maximumZoomScale) / 2.0;
        DebugLog(@"newScale: %f (%f, %f)", newScale, photoView.minimumZoomScale, photoView.maximumZoomScale);
        [photoView updateZoomScale:newScale];
    }
}

- (void)showMinimumSize:(id)sender {
    DebugLog(@"showMinimumSize");
    
    if ([self.view isKindOfClass:[PZPhotoView class]]) {
        PZPhotoView *photoView = (PZPhotoView *)self.view;
        [photoView updateZoomScale:photoView.minimumZoomScale];
    }
}

#pragma mark - Orientation
#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return TRUE;
}

#pragma mark - PZPhotoViewDelegate
#pragma mark -

- (void)photoViewDidSingleTap:(PZPhotoView *)photoView {
    DebugLog(@"photoViewDidSingleTap");
    [self.navigationController setToolbarHidden:!self.navigationController.toolbarHidden animated:TRUE];
}

- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView {
}

- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView {
}

@end
