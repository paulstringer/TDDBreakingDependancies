#import <Foundation/Foundation.h>

@interface MusicTrack : NSObject

@property (nonatomic, strong) NSString *trackID;
@property (nonatomic, strong) NSNumber *numberOfPlays;
@property (nonatomic, strong) NSNumber *recentPlays;

- (id)initWithTrackID:(NSString *)trackID ;

@end
