#import <Foundation/Foundation.h>

@class MusicTrack;

@interface MusicTrackListen : NSObject

@property (nonatomic, strong) MusicTrack *track;

+ (void)createListenWithTrack:(MusicTrack *)track andCompletion:(void (^)(MusicTrackListen *listen))completion;

- (NSDictionary *)jsonRepresentation;

@end
