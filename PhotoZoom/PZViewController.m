//
//  PZViewController.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZViewController.h"

#import "PZPhotoView.h"
#import "PZImagePalette.h"

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
    
    PZImagePalette *palette = [[PZImagePalette alloc] init];
    
    if ([self.view isKindOfClass:[PZPhotoView class]]) {
        PZPhotoView *photoView = (PZPhotoView *)self.view;
        photoView.photoViewDelegate = self;
//        [photoView displayImage:[UIImage imageNamed:@"Box.png"]];
        UIImage *image = [[palette images] objectAtIndex:4];
        [photoView displayImage:image];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    self.navigationController.toolbar.translucent = TRUE;
    self.navigationController.toolbar.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.translucent = TRUE;
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    [self setToolbarItems:self.customToolbarItems animated:FALSE];
    
    self.navigationController.navigationBar.hidden = FALSE;
    self.navigationController.toolbar.hidden = FALSE;
    [self.navigationController setNavigationBarHidden:FALSE animated:FALSE];
    [self.navigationController setToolbarHidden:FALSE animated:FALSE];
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

- (void)logRect:(CGRect)rect withName:(NSString *)name {
    DebugLog(@"%@: %f, %f / %f, %f", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)logLayout {
    [self logRect:self.view.bounds withName:@"scroll view bounds"];
    [self logRect:self.view.frame withName:@"scroll view frame"];
    
    UIView *imageView = [self.view.subviews objectAtIndex:0];
    [self logRect:imageView.bounds withName:@"image bounds"];
    [self logRect:imageView.frame withName:@"image frame"];
    
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    [self logRect:applicationFrame withName:@"application frame"];
    
    PZPhotoView *photoView = (PZPhotoView *)self.view;
    DebugLog(@"content size: %f, %f", photoView.contentSize.width, photoView.contentSize.height);
    DebugLog(@"content offset: %f, %f", photoView.contentOffset.x, photoView.contentOffset.y);
    DebugLog(@"content inset: %f, %f, %f, %f", photoView.contentInset.top, photoView.contentInset.right, photoView.contentInset.bottom, photoView.contentInset.left);
}

- (void)toggleFullScreen {
//    CGFloat duration = UINavigationControllerHideShowBarDuration;
    
    if ([self.navigationController isNavigationBarHidden]) {
        // fade in navigation
//        self.navigationController.navigationBar.alpha = 0.0;
//        self.navigationController.navigationBar.hidden = FALSE;
//        self.navigationController.toolbar.alpha = 0.0;
//        self.navigationController.toolbar.hidden = FALSE;
        
        // moving navbar down is necessary because it seems to be going under the status bar
        CGRect navbarFrame = self.navigationController.navigationBar.frame;
        navbarFrame.origin.y = 20.0;
        self.navigationController.navigationBar.frame = navbarFrame;
        
//        UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction;
//        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            [[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationFade];
            [self.navigationController setNavigationBarHidden:FALSE];
            [self.navigationController setToolbarHidden:FALSE];
//            self.navigationController.navigationBar.alpha = 1.0;
//            self.navigationController.toolbar.alpha = 1.0;
//        } completion:^(BOOL finished) {
//        }];
    }
    else {
        // fade out navigation
//        self.navigationController.navigationBar.alpha = 1.0;
//        self.navigationController.navigationBar.hidden = FALSE;
//        self.navigationController.toolbar.alpha = 1.0;
//        self.navigationController.toolbar.hidden = FALSE;
        
//        UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction;
//        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            [[UIApplication sharedApplication] setStatusBarHidden:TRUE withAnimation:UIStatusBarAnimationFade];
            [self.navigationController setNavigationBarHidden:TRUE];
            [self.navigationController setToolbarHidden:TRUE];

//            self.navigationController.navigationBar.alpha = 0.0;
//            self.navigationController.toolbar.alpha = 0.0;
//        } completion:^(BOOL finished) {
//            self.navigationController.navigationBar.hidden = TRUE;
//            self.navigationController.toolbar.hidden = TRUE;
//        }];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.navigationController.navigationBar setNeedsLayout];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.view setNeedsLayout];
    });

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
    [self toggleFullScreen];
}

- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView {
    // do nothing
}

- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView {
    // do nothing
}

- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView {
    [self logLayout];
}

@end
