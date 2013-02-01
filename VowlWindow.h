@interface VowlWindow : NSPanel 
{
    NSColor* savedBackgroundColor;
}

- (id)initWithContentRect:(NSRect)contentRect;

- (void)showChrome:(BOOL)flag;

@end
