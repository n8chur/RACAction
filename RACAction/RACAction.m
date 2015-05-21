//
//  RACAction.m
//  RACAction
//
//  Created by Justin Spahr-Summers on 2015-05-21.
//  Copyright (c) 2015 Automatic. All rights reserved.
//

#import "RACAction.h"

@implementation RACAction

- (instancetype)initWithEnabled:(RACSignal *)enabledSignal signalBlock:(RACSignal * (^)(id input))signalBlock {
    self = [super initWithEnabled:enabledSignal signalBlock:signalBlock];
    if (self == nil) return nil;

    _act_latestExecution = [[[[self.act_executions
        replayLast]
        take:1]
        flatten]
        setNameWithFormat:@"%@ -act_latestExecution", self];

    return self;
}

- (RACSignal *)act_executions {
    NSAssert(!super.allowsConcurrentExecution, @"RACActions are required to be serial, but %@ has concurreny enabled", self);

    RACSignal *errors = self.errors;

    return [[super.executionSignals
        map:^(RACSignal *execution) {
            RACSignal *doneExecuting = [execution ignoreValues];

            return [RACSignal
                merge:@[
                    execution,
                    [errors takeUntil:doneExecuting],
                ]];
        }]
        setNameWithFormat:@"%@ -act_executions", self];
}

- (RACSignal *)act_values {
    return [[super.executionSignals
        concat]
        setNameWithFormat:@"%@ -act_values", self];
}

#pragma mark - RACCommand

@dynamic allowsConcurrentExecution;
@dynamic executionSignals;

@end
