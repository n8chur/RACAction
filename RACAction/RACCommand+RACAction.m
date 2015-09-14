//
//  RACCommand+RACAction.m
//  RACAction
//
//  Created by Eric Horacek on 9/14/15.
//  Copyright (c) 2015 Automatic. All rights reserved.
//

#import "RACCommand+RACAction.h"

@implementation RACCommand (RACAction)

- (RACSignal *)act_executions {
    NSAssert(!self.allowsConcurrentExecution, @"%@ is required to be serial to invoke %@, but %@ has concurreny enabled", NSStringFromClass(self.class), NSStringFromSelector(_cmd), self);

    RACSignal *errors = [self.errors flattenMap:^(NSError *error) {
        return [RACSignal error:error];
    }];

    RACSignal *doneExecuting = [self.executing filter:^ BOOL (NSNumber *executing) {
        return !executing.boolValue;
    }];

    return [[self.executionSignals
        map:^(RACSignal *execution) {
            return [[RACSignal
                merge:@[
                    execution,
                    [errors takeUntil:doneExecuting],
                ]]
                replay];
        }]
        setNameWithFormat:@"%@ -act_executions", self];
}

- (RACSignal *)act_values {
    return [[self.executionSignals
        concat]
        setNameWithFormat:@"%@ -act_values", self];
}

- (RACSignal *)act_latestExecution {
    return [[[[self.act_executions
        replayLast]
        take:1]
        flatten]
        setNameWithFormat:@"%@ -act_latestExecution", self];
}

@end
