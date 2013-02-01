@interface SFFlickrPhoto : NSObject
{
	NSInteger farm;
	NSString* photoID;
	BOOL isFamily;
	BOOL isFriend;
	BOOL isPublic;
	NSString* owner;
	NSString* secret;
	NSString* server;
	NSString* title;
	NSURL* cachedDirectURL;
	NSURL* cachedPageURL;
}

@property (readwrite, assign) NSInteger farm;
@property (readwrite, copy) NSString* photoID;
@property (readwrite, assign) BOOL isFamily;
@property (readwrite, assign) BOOL isFriend;
@property (readwrite, assign) BOOL isPublic;
@property (readwrite, copy) NSString* owner;
@property (readwrite, copy) NSString* secret;
@property (readwrite, copy) NSString* server;
@property (readwrite, copy) NSString* title;

+ (id)photoWithAttributes:(NSDictionary*)attrs;

- (id)initWithAttributes:(NSDictionary*)attrs;

- (NSURL*)directURL;
- (NSURL*)pageURL;

@end
