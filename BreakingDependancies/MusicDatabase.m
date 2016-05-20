#import <MediaPlayer/MediaPlayer.h>
#import "MusicDatabase.h"
#import "MusicTrack.h"
#import "DatabaseConnection.h"

@implementation MusicDatabase

+ (void)initialize
{
    if (self == [MusicDatabase class]) {
        
    }
}

+ (MusicDatabase *)sharedManager
{
    static MusicDatabase *_sharedManager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[MusicDatabase alloc] init];
    });
    
    return _sharedManager;
}

- (void)allTracksWithCompletionHandler:(void (^)(NSArray *))completion {
    
    if ( completion != nil ) {
        completion(@[  [[MusicTrack alloc] initWithTrackID:@"1"] ]);
    }
    
}

- (void)insertOrUpdateTrackWithMediaItemID:(NSString *)trackID andMPMediaItem:(MPMediaItem*)item withCompletionHandler:(void (^)(MusicTrack *track))completion {
    
    if ( completion != nil ) {
        MusicTrack *track  = [[MusicTrack alloc] initWithTrackID:trackID];
        completion(track);
    }
}

- (DatabaseConnection*) connection {
    return nil;
}

@end
