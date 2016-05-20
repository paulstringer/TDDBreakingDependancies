//
//  DatabaseTransaction.h
//  BreakingDependancies
//
//  Created by Paul Stringer on 20/05/2016.
//  Copyright © 2016 stringerstheory. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseTransaction : NSObject

- (void) setObject:(id)object forKey:(NSString*)key inCollection:(NSString*)collection;
@end
