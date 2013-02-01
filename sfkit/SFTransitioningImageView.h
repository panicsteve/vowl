@class SFClickableImageView;

@interface SFTransitioningImageView : NSView
{
	SFClickableImageView* imageView1;
	SFClickableImageView* imageView2;
	
	SFClickableImageView* currentImageView;
}

- (void)setAction:(SEL)inAction;
- (void)setTarget:(id)inTarget;

- (void)transitionToImage:(NSImage*)newImage;

@end
