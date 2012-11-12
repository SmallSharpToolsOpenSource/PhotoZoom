//
//  PZPagingScrollView.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 11/9/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZPagingScrollView.h"

#pragma mark -  Class Extension
#pragma mark -

@interface PZPagingScrollView () <UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *pagingViews;

@property (strong, nonatomic) NSMutableSet *recycledPages;
@property (strong, nonatomic) NSMutableSet *visiblePages;


@end

@implementation PZPagingScrollView {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        
        self.recycledPages = [[NSMutableSet alloc] init];
        self.visiblePages  = [[NSMutableSet alloc] init];

    }
    return self;
}

- (CGSize)calculatedContentSize {
    CGFloat width = self.frame.size.width * self.pagingViews.count;
    return CGSizeMake(width, self.frame.size.height);
}

#define PADDING  4

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    
    CGRect pageFrame = self.bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (self.bounds.size.width * index) + PADDING;
    
    return pageFrame;
}

#pragma mark - Public Implementation
#pragma mark -

- (void)displayPagingViews:(NSArray *)pagingViews atIndex:(NSUInteger)index {
    self.pagingViews = pagingViews;

    // 1) clear out the sub views
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    // 2) set the content size for all of the paging views
    self.contentSize = [self calculatedContentSize];
    
    // 3) scroll to the given index
    
    // 4) position the visible view
    
    // 5) position views before and after view as an optimization
    
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

@end
