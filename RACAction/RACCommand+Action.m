//
//  RACCommand+Action.m
//  RACAction
//
//  Created by Justin Spahr-Summers on 2015-05-21.
//  Copyright (c) 2015 Automatic. All rights reserved.
//

#import "RACCommand+Action.h"

@implementation RACCommand (Action)

- (RACSignal *)act_executions {
    NSAssert(!self.allowsConcurrentExecution, @"%s is only supported for serial commands, %@ has concurrent execution enabled", sel_getName(_cmd), self);

    RACSignal *errors = self.errors;

    return [self.executionSignals map:^(RACSignal *execution) {
        RACSignal *doneExecuting = [execution ignoreValues];

        return [RACSignal
            merge:@[
                execution,
                [errors takeUntil:doneExecuting],
            ]];
    }];
}

- (RACSignal *)act_values {
    return [self.executionSignals concat];
}

@end
