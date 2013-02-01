@class SFFlickrClient;

@protocol SFFlickrClientDelegate

@required

- (void)flickrClientReceivedPhotos:(SFFlickrClient*)flickrClient;
- (void)flickrClient:(SFFlickrClient*)flickrClient receivedImage:(NSImage*)image;

@optional

@end
