//
//  DatabaseConnection.h
//  BreakingDependancies
//
//  Created by Paul Stringer on 20/05/2016.
//  Copyright © 2016 stringerstheory. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DatabaseTransaction;

@interface DatabaseConnection : NSObject

- (void)readWriteWithBlock:(void (^) (DatabaseTransaction* transaction))readwriteBlock;

@end
