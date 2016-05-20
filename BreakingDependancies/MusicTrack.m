#import "MusicTrack.h"

@implementation MusicTrack

- (id)initWithTrackID:(NSString *)trackID {
    
    if (self == [super init]) {
        _numberOfPlays = @(0);
        _trackID = trackID;
    }
    
    return self;
    
}

@end
