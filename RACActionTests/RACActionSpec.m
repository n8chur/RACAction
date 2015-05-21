//
//  RACActionSpec.m
//  RACAction
//
//  Created by Justin Spahr-Summers on 2015-05-21.
//  Copyright (c) 2015 Automatic. All rights reserved.
//

@import Expecta;
@import RACAction;
@import ReactiveCocoa;
@import Specta;

SpecBegin(RACAction)

__block RACAction *action;
__block BOOL shouldError;

NSError *testError = [NSError errorWithDomain:@"com.automatic.RACAction" code:1 userInfo:nil];

beforeEach(^{
    shouldError = NO;
    action = [[RACAction alloc] initWithSignalBlock:^(NSNumber *input) {
        if (shouldError) {
            return [RACSignal error:testError];
        }

        NSNumber *doubled = @(input.integerValue * 2);
        return [[RACSignal
            return:doubled]
            startWith:input];
    }];

    expect(action).notTo.beNil();
});

describe(@"-act_executions", ^{
    __block RACSignal *execution;

    beforeEach(^{
        execution = nil;
        [action.act_executions subscribeNext:^(RACSignal *signal) {
            execution = signal;
        }];
    });

    it(@"should send execution signals", ^{
        expect([[action execute:@1] asynchronouslyWaitUntilCompleted:NULL]).to.beTruthy();

        expect(execution).notTo.beNil();
        expect([execution toArray]).to.equal((@[ @1, @2 ]));
    });

    it(@"should forward errors on execution signals", ^{
        shouldError = YES;

        __block NSError *error = nil;
        expect([[action execute:@1] asynchronouslyWaitUntilCompleted:&error]).to.beFalsy();
        expect(error).to.equal(testError);

        expect(execution).notTo.beNil();
        expect([execution waitUntilCompleted:&error]).to.beFalsy();
        expect(error).to.equal(testError);
    });
});

describe(@"-act_values", ^{
    it(@"should send values as they occur", ^{
        NSMutableArray *values = [NSMutableArray array];
        [action.act_values subscribeNext:^(id value) {
            [values addObject:value];
        }];

        expect([[action execute:@2] asynchronouslyWaitUntilCompleted:NULL]).to.beTruthy();
        expect(values).to.equal((@[ @2, @4 ]));
    });
});

describe(@"-act_latestExecution", ^{
    it(@"should forward next execution", ^{
        NSMutableArray *values = [NSMutableArray array];
        [action.act_latestExecution subscribeNext:^(id value) {
            [values addObject:value];
        }];
        
        expect([[action execute:@2] asynchronouslyWaitUntilCompleted:NULL]).to.beTruthy();
        expect(values).to.equal((@[ @2, @4 ]));
    });

    it(@"should send errors from execution", ^{
        __block NSError *receivedError = nil;
        [action.act_latestExecution subscribeError:^(NSError *error) {
            receivedError = error;
        }];
        
        shouldError = YES;
        expect([[action execute:@2] asynchronouslyWaitUntilCompleted:NULL]).to.beFalsy();
        expect(receivedError).to.equal(testError);
    });

    it(@"should replay last execution", ^{
        expect([[action execute:@2] asynchronouslyWaitUntilCompleted:NULL]).to.beTruthy();
        expect([action.act_latestExecution toArray]).to.equal((@[ @2, @4 ]));
    });
});

SpecEnd
