#import "DatabaseConnection.h"
#import "DatabaseTransaction.h"

@implementation DatabaseConnection

- (void)readWriteWithBlock:(void (^) (DatabaseTransaction* transaction))readwriteBlock {
    if (readwriteBlock) {
     readwriteBlock([DatabaseTransaction new]);
    }
}

@end
