PhotoZoom
===================

## iOS project which closely mimics the behavior of the Apple Photos app.

### Overview

There are lots of photo browsing projects. You can find some on [Cocoa Controols](http://www.cocoacontrols.com/tags/photo) but I
did not find them to met my needs. I wanted something that is very simple which could be dropped into an app easily. This solution
is simply an extension of UIScrollView with the addition of tap gestures.

The project was built by referencing the PhotoScroller and AutoScroll samples from Apple. (See @elizablock on Twitter)

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
with delegates to handle anything which is unique so it is easier to reuse and extend. This way I can drop multiple views 
into a parent view and get all of the functionality without any trouble. It's possible there could be multiple paging scroll 
views managed inside a view controller like an a news app like Pulse. This paging scroll view could be placed into a NIB 
managed inside of a Storyboard and just set the base class to align it with your own inherited version of the view which 
can implement delegate methods as you need them.

### Reuse

To use these classes in your own project you only need PZPagingScrollView and PZPhotoView. The rest is just for reference
on how it should work.

### Caveats

The geometry can be tricky when managing a scroll view within a scroll view. Then there is the process of hiding and showing
the status bar, navbar and toolbar which can distort the layout and require observing those changes and adapting with
by coding adaptations or to better manage the layout with autoresizing. I found it very difficult to toggle full screen
mode due to the side effects to the layout. I tried to mimic the behavior in the Photos app but from the public API I do
not seem to have a safe way to animate the status bar and other bars in sync with each other. So I have simply done the
best that I can do. There is a jump due to the status bar which I would prefer to eliminate once I can learn a better 
approach. Once I get some answers on the developer forums or Stackoverflow I may be able to update this code to provide
a smoother transition.

### Quirks

Something odd about this project is the fact that the NavigationBar does not show by default. I have to make it visible
with code. That does not make sense as it should show by default. I need to learn why that is happening and fix it. It 
may simply be a bug with Xcode with the frequence changes to Interface Builder recently and it will work itself out
automatically.

Brennan Stehling  
SmallSharpTools LLC  
www.smallsharptools.com  
