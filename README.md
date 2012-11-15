PhotoZoom
===================

### iOS project to show how to use gestures to zoom a photo.

### Overview

There are lots of photo browsing projects. You can find some on [Cocoa Controols](http://www.cocoacontrols.com/tags/photo) but I
did not find they met my needs. I wanted something that is very simple which could be dropped into an app easily. This solution
is simply an extension of UIScrollView with the addition of tap gestures.

The project was built by referencing the PhotoScroller and AutoScroll samples from Apple.

### View Controller and Views Hierarchy

In this project the hierarchy goes like the following:

PZViewController -> PZPagingScrollView -> PZPhotoView

The PZViewController implements delegate methods to generate the views which are displayed in a scroll view by
PZPagingScrollView. These views are all instances of PZPhotoView and one delegate method handles the configuration
of each instance to display an image. It's possible to implement the delegate methods differently to put anything
into a paging scroll view. Currently images are generated with a NIB as a palette to keep things self-contained to
facilitate testing. Downloading actual images could be done next. This approach avoids loading all of the images at
the same time to avoid exessive memory usage. The delegate methods could even handle different kinds of views inside
of the paging scroll view.

The tricky parts are going into and out of full screen mode by hiding each of the bars as well as rotation. Logging
out the layout from the top down to the bottom views was helpful in seeing what was happening. There seem to be lots
of side effects which I do not usually expect so I had to observe and respond to them. More work needs to be done to
ensure these hacks can be made more reliable across future releases and potentially make it compatible with iOS 5 which
has not been tested at all.

### Approach

I could have put more of the code into view controllers but I am finding that coding inside of views to work better along
with delegates to handle anything which is unique. This way I can drop multiple views into a parent view and get all of
the functionality without any trouble. It's possible there could be multiple paging scroll views managed a view controller
like an a news app like Pulse. This paging scroll view could be placed into a NIB managed inside of a Storyboard and
just set up the base class to align it with your own inherited version of the view which can implement delegate methods
as you need them.

### Reuse

To use these classes in your own project you only need PZPagingScrollView and PZPhotoView. The rest is just for reference
on how it should work.

Brennan Stehling  
SmallSharpTools LLC  
www.smallsharptools.com  
