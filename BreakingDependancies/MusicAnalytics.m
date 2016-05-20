
#import "MusicAnalytics.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MusicDiff.h"

@interface MusicAnalytics ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property BOOL paused;
@property (strong,nonatomic)MPMediaItem *nowPlayingItem;
@end


@implementation MusicAnalytics


+ (void)initialize
{
    if (self == [MusicAnalytics class]) {
        
    }
}


+ (MusicAnalytics *)sharedTracker
{
    static MusicAnalytics *_sharedTracker;
    static dispatch_once_t onceToken;
    
    
    dispatch_once(&onceToken, ^{
        _sharedTracker = [[MusicAnalytics alloc] init];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:_sharedTracker
                               selector:@selector(handleNowPlayingItemChanged:)
                                   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                 object:[MPMusicPlayerController systemMusicPlayer]];
        [notificationCenter addObserver:_sharedTracker
                               selector:@selector(playbackStateDidChange:)
                                   name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                 object:[MPMusicPlayerController systemMusicPlayer]];
        [[MPMusicPlayerController systemMusicPlayer]beginGeneratingPlaybackNotifications];
        
    });
    
    return _sharedTracker;
}
-(void)handleNowPlayingItemChanged:(NSNotification*)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MusicDiff sharedManager] process];
    });
}
-(void)playbackStateDidChange:(NSNotification*)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MusicDiff sharedManager] process];
    });
}


@end
