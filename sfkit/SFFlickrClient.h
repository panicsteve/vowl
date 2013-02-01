#import "SFFlickrClientDelegate.h"
#import "SFRestRequestDelegate.h"

@class SFFlickrPhoto;

@interface SFFlickrClient : NSObject <SFRestRequestDelegate, NSXMLParserDelegate/*, NSURLDownloadDelegate*/>
{
	NSString* apiKey;
	NSObject<SFFlickrClientDelegate>* delegate;
	NSURLDownload* download;
	NSMutableArray* outArray;
	SFRestRequest* requestInProgress;
}

@property (readwrite, copy) NSString* apiKey;
@property (readwrite, assign) NSObject<SFFlickrClientDelegate>* delegate;

- (id)initWithAPIKey:(NSString*)apiKey;

- (void)cancelOperations;

- (void)requestImageForPhoto:(SFFlickrPhoto*)photo;
- (void)requestPhotosWithTags:(NSArray*)tags intoArray:(NSMutableArray*)array perPage:(NSNumber*)perPage page:(NSNumber*)page;

@end
