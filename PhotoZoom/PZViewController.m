//
//  PZViewController.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZViewController.h"

#import "PZPagingScrollView.h"
#import "PZPhotoView.h"
#import "PZImagePalette.h"

@interface PZViewController () <PZPagingScrollViewDelegate, PZPhotoViewDelegate, UIScrollViewDelegate>

@property (readonly) NSArray *customToolbarItems;

@property (strong, nonatomic) NSArray *images;

@property (weak, nonatomic) IBOutlet PZPagingScrollView *pagingScrollView;

@end

@implementation PZViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.toolbar.translucent = TRUE;
    self.navigationController.toolbar.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.translucent = TRUE;
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    [self setToolbarItems:self.customToolbarItems animated:FALSE];

    self.navigationController.navigationBar.hidden = FALSE;
    self.navigationController.toolbar.hidden = FALSE;
    [self.navigationController setNavigationBarHidden:FALSE animated:FALSE];
    [self.navigationController setToolbarHidden:FALSE animated:FALSE];
    
    PZImagePalette *palette = [[PZImagePalette alloc] init];
    self.images = palette.images;
    [self.pagingScrollView displayPagingViewAtIndex:0];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.pagingScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    });

//    [self logLayout];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    // suspend tiling while rotating
    self.pagingScrollView.suspendTiling = TRUE;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    self.pagingScrollView.suspendTiling = FALSE;
    [self.pagingScrollView resetDisplay];
}

#pragma mark - User Actions
#pragma mark -

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
    PZPhotoView *photoView = (PZPhotoView *)self.pagingScrollView.visiblePageView;
    [photoView updateZoomScale:photoView.maximumZoomScale];
}

- (void)showMediumSize:(id)sender {
    PZPhotoView *photoView  = (PZPhotoView *)self.pagingScrollView.visiblePageView;
    float newScale = (photoView.minimumZoomScale + photoView.maximumZoomScale) / 2.0;
    [photoView updateZoomScale:newScale];
}

- (void)showMinimumSize:(id)sender {
    PZPhotoView *photoView  = (PZPhotoView *)self.pagingScrollView.visiblePageView;
    [photoView updateZoomScale:photoView.minimumZoomScale];
}

- (void)toggleFullScreen {    
    if (self.navigationController.navigationBar.alpha == 0.0) {
        // fade in navigation
        
        [UIView animateWithDuration:0.4 animations:^{
            [[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationNone];
            self.navigationController.navigationBar.alpha = 1.0;
            self.navigationController.toolbar.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }
    else {
        // fade out navigation
        
        [UIView animateWithDuration:0.4 animations:^{
            [[UIApplication sharedApplication] setStatusBarHidden:TRUE withAnimation:UIStatusBarAnimationFade];
            self.navigationController.navigationBar.alpha = 0.0;
            self.navigationController.toolbar.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - Layout Debugging Support
#pragma mark -

- (void)logRect:(CGRect)rect withName:(NSString *)name {
    DebugLog(@"%@: %f, %f / %f, %f", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)logLayout {
    DebugLog(@"### PZViewController ###");
    [self logRect:self.view.window.bounds withName:@"self.view.window.bounds"];
    [self logRect:self.view.window.frame withName:@"self.view.window.frame"];

    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    [self logRect:applicationFrame withName:@"application frame"];
    
    if ([self.pagingScrollView respondsToSelector:@selector(logLayout)]) {
        [self.pagingScrollView performSelector:@selector(logLayout)];
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

#pragma mark - PZPagingScrollViewDelegate
#pragma mark -

- (Class)pagingScrollView:(PZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    // all page views are photo views
    return [PZPhotoView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(PZPagingScrollView *)pagingScrollView {
    return self.images.count;
}

- (UIView *)pagingScrollView:(PZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:self.view.bounds];
    photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    photoView.photoViewDelegate = self;
    
    return photoView;
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    assert([pageView isKindOfClass:[PZPhotoView class]]);
    assert(index < self.images.count);
    
    PZPhotoView *photoView = (PZPhotoView *)pageView;
    UIImage *image = [self.images objectAtIndex:index];
    [photoView displayImage:image];
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
