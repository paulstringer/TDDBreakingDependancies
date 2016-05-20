#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedManager;

- (void)postListens:passingDictionary withCompletion:(void(^)(id results, NSInteger errorCode, NSDictionary *errorDict))completion;

@end
