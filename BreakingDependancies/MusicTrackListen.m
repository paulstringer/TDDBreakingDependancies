#import "MusicTrackListen.h"

@implementation MusicTrackListen

+ (void)createListenWithTrack:(MusicTrack *)track andCompletion:(void (^)(MusicTrackListen *listen))completion {
    if (completion) {
        completion([MusicTrackListen new]);
    }
}

- (NSDictionary *)jsonRepresentation {
    return @{};
}
@end
