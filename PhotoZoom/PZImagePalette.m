//
//  PZImagePalette.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 11/9/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZImagePalette.h"

#pragma mark -  Class Extension
#pragma mark -

@interface PZImagePalette ()

@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (strong, nonatomic) IBOutlet UIView *view3;
@property (strong, nonatomic) IBOutlet UIView *view4;
@property (strong, nonatomic) IBOutlet UIView *view5;

@end

@implementation PZImagePalette

+ (NSString *)nibName {
    return NSStringFromClass(self);
}

- (id)init {
    self = [super init];
    
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:[PZImagePalette nibName] owner:self options:nil];
        assert(self.view1 != nil);
        assert(self.view2 != nil);
        assert(self.view3 != nil);
        assert(self.view4 != nil);
        assert(self.view5 != nil);
    }
    
    return self;
}

- (NSArray *)images {
    NSMutableArray *images = [NSMutableArray array];
    
    NSArray *views = @[self.view1, self.view2, self.view3, self.view4, self.view5];
    for (UIView *view in views) {
        [images addObject:[self createImageWithView:view]];
    }
    
    return images;
}

- (UIImage *)createImageWithView:(UIView *)view {
	UIImage *image = nil;
	
	UIGraphicsBeginImageContext(view.frame.size);
	{
		[view.layer renderInContext: UIGraphicsGetCurrentContext()];
		image = UIGraphicsGetImageFromCurrentImageContext();
	}
	UIGraphicsEndImageContext();

    return image;
}

@end
