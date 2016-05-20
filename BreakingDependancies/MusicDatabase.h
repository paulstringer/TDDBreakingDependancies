#import <Foundation/Foundation.h>

@class MPMediaItem;
@class MusicTrack;
@class DatabaseConnection;

@interface MusicDatabase : NSObject

+ (MusicDatabase *)sharedManager;

- (void) allTracksWithCompletionHandler:(void (^)(NSArray *))completion;

- (void)insertOrUpdateTrackWithMediaItemID:(NSString *)trackID andMPMediaItem:(MPMediaItem*)item withCompletionHandler:(void (^)(MusicTrack *track))completion;

- (DatabaseConnection*) connection;

@end
