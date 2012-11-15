PhotoZoom
===================

### iOS project to show how to use gestures to zoom a photo.

### Overview

There are lots of photo browsing projects. You can find some on [Cocoa Controols](http://www.cocoacontrols.com/tags/photo) but I
did not find they met my needs. I wanted something that is very simple which could be dropped into an app easily. This solution
is simply an extension of UIScrollView with the addition of tap gestures.

The project was built by referencing the PhotoScroller and AutoScroll samples from Apple.

In this project the hierarchy goes like the following:

PZViewController -> PZPagingScrollView -> PZPhotoView

The PZViewController implements delegate methods to generate the views which are displayed in a scroll view by
PZPagingScrollView. These views are all instances of PZPhotoView and one delegate method handles the configuration
of each instance to display an image. It's possible to implement the delegate methods differently to put anything
into a paging scroll view.

The tricky parts are going into and out of full screen mode by hiding each of the bars as well as rotation. Logging
out the layout from the top down to the bottom views was helpful in seeing what was happening. There seem to be lots
of side effects which I do not usually expect so I had to observe and respond to them. More work needs to be done to
ensure these hacks can be made more reliable across future releases and potentially make it compatible with iOS 5 which
has not been tested at all.

