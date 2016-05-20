#import <MediaPlayer/MediaPlayer.h>
#import "MusicDiff.h"
#import "MusicDatabase.h"
#import "MusicTrack.h"
#import "MusicTrackListen.h"
#import <AdSupport/AdSupport.h>
#import "NetworkManager.h"
#import "DatabaseConnection.h"
#import "DatabaseTransaction.h"

@interface MusicDiff ()
@property (nonatomic,strong)__block NSMutableArray *tracksToProcess;
@property (nonatomic) __block BOOL processing;
@end

NSString * const kMusicUpdating = @"MusicDiffProcessingNotification";
NSString * const kMusicPercentComplete = @"MusicDiffProcessingPercentComplete";

@implementation MusicDiff

+ (void)initialize
{
    if (self == [MusicDiff class]) {
        
    }
}

+ (MusicDiff *)sharedManager
{
    static MusicDiff *_sharedManager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[MusicDiff alloc] init];
    });
    
    return _sharedManager;
}

- (void) process {
    
    if(_processing)
        return;
    
    [self setProcessing:YES];
    if (_tracksToProcess==nil) {
        _tracksToProcess = [[NSMutableArray alloc]init];
    }else{
        [_tracksToProcess removeAllObjects];
    }
    [[MusicDatabase sharedManager] allTracksWithCompletionHandler:^(NSArray *songs) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
            __block NSInteger lastReadDate  = 0;
            if([[NSUserDefaults standardUserDefaults]integerForKey:@"lastItunesProcessDate"]>0){
                lastReadDate = [[NSUserDefaults standardUserDefaults]integerForKey:@"lastItunesProcessDate"];
            }else{
                lastReadDate = [[NSDate dateWithTimeIntervalSinceNow:-2628000]timeIntervalSince1970];
            }
            MPMediaQuery *query = [[MPMediaQuery alloc] init];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeMusic] forProperty:MPMediaItemPropertyMediaType]];
            NSArray *items = [query items];
            NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyPlayCount ascending:NO];
            NSArray *newItems = [items sortedArrayUsingDescriptors:@[sorter]];
            NSMutableArray *playedItems = [NSMutableArray array];
            for (MPMediaItem *item in newItems) {
                if([item playCount]>0){
                    [playedItems addObject:item];
                }
            }
            newItems=nil;
            query=nil;
            __block NSMutableArray *itemsToUpdate = [NSMutableArray array];
            if([playedItems count]){
                for (int i =0; i<[playedItems count]; i++) {
                    NSString *trackID = [NSString stringWithFormat:@"%llu", [(NSNumber *)[(MPMediaItem*)[playedItems objectAtIndex:i] valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue]];
                    BOOL shouldUpdate = NO;
                    BOOL hasBeenFound = NO;
                    for (MusicTrack *track in songs) {
                        if ([track.trackID isEqualToString:trackID]) {
                            hasBeenFound = YES;
                            if([[(MPMediaItem*)[playedItems objectAtIndex:i]valueForProperty:MPMediaItemPropertyPlayCount]intValue]>[[track numberOfPlays]intValue]){
                                shouldUpdate=YES;
                            }
                        }
                    }
                    if(shouldUpdate||!hasBeenFound){
                        [itemsToUpdate addObject:(MPMediaItem*)[playedItems objectAtIndex:i]];
                    }
                }
                if([itemsToUpdate count]){
                    __block int index = 0;
                    __block NSMutableArray *listens = [NSMutableArray array];
                    for (MPMediaItem *item in itemsToUpdate) {
                        NSString *trackID = [NSString stringWithFormat:@"%llu", [(NSNumber *)[item valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue]];
                        [[MusicDatabase sharedManager] insertOrUpdateTrackWithMediaItemID:trackID andMPMediaItem:item withCompletionHandler:^(MusicTrack *track) {
                            if(track){
                                [MusicTrackListen createListenWithTrack:track andCompletion:^(MusicTrackListen *listen) {
                                    [listens addObject:listen];
                                    index++;
                                    [[NSNotificationCenter defaultCenter]postNotificationName:kMusicUpdating object:nil userInfo:@{kMusicPercentComplete:[NSNumber numberWithFloat:(float)((float)index/(float)[itemsToUpdate count])]}];
                                    if(index==[itemsToUpdate count]){
                                        if([listens count]){
                                            NSMutableDictionary *passingDictionary = [[NSMutableDictionary alloc]initWithDictionary: @{@"deviceId":[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString],@"timestamp":@((long long)([[NSDate date] timeIntervalSince1970]*1000))}];
                                            NSMutableArray *listensArray = [NSMutableArray array];
                                            for (MusicTrackListen *listen in listens) {
                                                [listensArray addObject:listen.jsonRepresentation];
                                            }
                                            if([[NSUserDefaults standardUserDefaults]boolForKey:@"passedInitialListens"]){
                                                [passingDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"historical"];
                                            }else{
                                                [passingDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"historical"];
                                                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"passedInitialListens"];
                                                [[NSUserDefaults standardUserDefaults]synchronize];
                                            }
                                            if(listensArray.count){
                                                [passingDictionary setObject:listensArray forKey:@"tracks"];
                                                [[NetworkManager sharedManager] postListens:passingDictionary withCompletion:^(id results, NSInteger errorCode, NSDictionary *errorDict) {
                                                    if(errorCode==200||errorCode==201){
                                                        [[NSUserDefaults standardUserDefaults]setInteger:[[NSDate date]timeIntervalSince1970] forKey:@"lastItunesProcessDate"];
                                                        [[NSUserDefaults standardUserDefaults]synchronize];
                                                    }else{
                                                        for (MusicTrackListen *listen in listens) {
                                                            __block MusicTrack *track = [listen track];
                                                            [track setNumberOfPlays:[NSNumber numberWithInt:[[[listen track]numberOfPlays]intValue]-[[[listen track]recentPlays]intValue]]];
                                                            [track setRecentPlays:@(0)];
                                                            [[[MusicDatabase sharedManager] connection] readWriteWithBlock:^(DatabaseTransaction *transaction) {
                                                                [transaction setObject:track forKey:track.trackID inCollection:@"Track"];
                                                            }];
                                                        }
                                                    }
                                                    [self setProcessing:NO];
                                                }];
                                            }
                                        }
                                    }
                                }];
                            }else{
                                index++;
                            }
                        }];
                    }
                }else{
                    [[NSNotificationCenter defaultCenter]postNotificationName:kMusicUpdating object:nil userInfo:@{kMusicPercentComplete:@(1)}];
                    [self setProcessing:NO];
                }
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:kMusicUpdating object:nil userInfo:@{kMusicPercentComplete:@(1)}];
                [self setProcessing:NO];
            }
        });
    }];
    
    
    
}


@end
