//
//  RACAction.m
//  RACAction
//
//  Created by Justin Spahr-Summers on 2015-05-21.
//  Copyright (c) 2015 Automatic. All rights reserved.
//

#import "RACAction.h"

@implementation RACAction

- (RACSignal *)act_executions {
    NSAssert(!super.allowsConcurrentExecution, @"%s is only supported for serial commands, %@ has concurrent execution enabled", sel_getName(_cmd), self);

    RACSignal *errors = self.errors;

    return [super.executionSignals map:^(RACSignal *execution) {
        RACSignal *doneExecuting = [execution ignoreValues];

        return [RACSignal
            merge:@[
                execution,
                [errors takeUntil:doneExecuting],
            ]];
    }];
}

- (RACSignal *)act_values {
    return [super.executionSignals concat];
}

#pragma mark - RACCommand

@dynamic allowsConcurrentExecution;
@dynamic executionSignals;

@end
