#import "NetworkManager.h"

@implementation NetworkManager

+ (void)initialize
{
    if (self == [NetworkManager class]) {
        
    }
}

+ (NetworkManager *)sharedManager
{
    static NetworkManager *_sharedManager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[NetworkManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)postListens:passingDictionary withCompletion:(void(^)(id results, NSInteger errorCode, NSDictionary *errorDict))completion {
    
    
    if ( completion ) {
        
        completion(@{@"result":@"OK"}, 0, nil);
        
    }
}

@end
