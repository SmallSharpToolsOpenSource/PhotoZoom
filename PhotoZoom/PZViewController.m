//
//  PZViewController.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZViewController.h"

#import <CoreGraphics/CoreGraphics.h>

#import "PZPhotoView.h"
#import "PZPhotosDataSource.h"

@interface PZViewController () <PZPhotoViewDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (readonly) NSArray *customToolbarItems;

@property (strong, nonatomic) PZPhotosDataSource *photosDataSource;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PZViewController {
    BOOL _isFullScreen;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photosDataSource = [[PZPhotosDataSource alloc] init];
}

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // resetDisplay will set the content size and position the frames (not ideal to do it this way)
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
                                    initWithTitle:@"Maximum"
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

- (PZPhotoView *)visiblePhotoView {
    NSArray *visibleCells = [self.collectionView visibleCells];
    
    if (visibleCells.count) {
        UIView *cell = visibleCells[0];
        UIView *view = [cell viewWithTag:1];
        if ([view isKindOfClass:[PZPhotoView class]]) {
            return (PZPhotoView *)view;
        }
    }
    
    return nil;
}

- (void)showMaximumSize:(id)sender {
    PZPhotoView *photoView = [self visiblePhotoView];
    [photoView updateZoomScale:photoView.maximumZoomScale];
}

- (void)showMediumSize:(id)sender {
    PZPhotoView *photoView = [self visiblePhotoView];
    CGFloat newScale = (photoView.minimumZoomScale + photoView.maximumZoomScale) / 2.0;
    [photoView updateZoomScale:newScale];
}

- (void)showMinimumSize:(id)sender {
    PZPhotoView *photoView = [self visiblePhotoView];
    [photoView updateZoomScale:photoView.minimumZoomScale];
}

- (void)toggleFullScreen {

    DebugLog(@"toggling full screen");
    
    _isFullScreen = !_isFullScreen;
    
    if (!_isFullScreen) {
        // fade in navigation
        
        DebugLog(@"fading in");
        
        [UIView animateWithDuration:0.4 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            self.navigationController.navigationBar.alpha = 1.0;
            self.navigationController.toolbar.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }
    else {
        // fade out navigation
        
        DebugLog(@"fading out");
        
        [UIView animateWithDuration:0.4 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            self.navigationController.navigationBar.alpha = 0.0;
            self.navigationController.toolbar.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }
}

- (BOOL)prefersStatusBarHidden {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    return _isFullScreen;
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

#pragma mark - UICollectionViewDelegate
#pragma mark -

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoView" forIndexPath:indexPath];
    
    UIView *view = [cell viewWithTag:1];
    if ([view isKindOfClass:[PZPhotoView class]]) {
        PZPhotoView *photoView = (PZPhotoView *)view;
        
        [photoView prepareForReuse];
        
        [photoView startWaiting];
        [self.photosDataSource photoForIndex:indexPath.item withCompletionBlock:^(UIImage *photo, NSError *error) {
            [photoView stopWaiting];
            if (error != nil) {
                DebugLog(@"Error: %@", error);
            }
            else {
                [photoView displayImage:photo];
            }
        }];
    }
    
    return cell;
}

@end
