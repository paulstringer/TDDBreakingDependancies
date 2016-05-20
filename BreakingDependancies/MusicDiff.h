#import <Foundation/Foundation.h>

extern NSString * const kMusicUpdating;

@interface MusicDiff : NSObject

+ (MusicDiff *)sharedManager;

- (void) process;

@end
