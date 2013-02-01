@interface SFFlickrTag : NSObject <NSCoding>
{
	NSString* name;
}

+ (id)tagWithName:(NSString*)inName;

@property (readwrite, copy) NSString* name;

@end
