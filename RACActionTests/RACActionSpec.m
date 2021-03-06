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

__block RACCommand *command;
__block BOOL shouldError;

NSError *testError = [NSError errorWithDomain:@"com.automatic.RACAction" code:1 userInfo:nil];

beforeEach(^{
    shouldError = NO;
    command = [[RACCommand alloc] initWithSignalBlock:^(NSNumber *input) {
        if (shouldError) {
            return [RACSignal error:testError];
        }

        NSNumber *doubled = @(input.integerValue * 2);
        return [[RACSignal
            return:doubled]
            startWith:input];
    }];

    expect(command).notTo.beNil();
});

describe(@"-act_executions", ^{
    __block RACSignal *execution;

    beforeEach(^{
        execution = nil;
        [command.act_executions subscribeNext:^(RACSignal *signal) {
            execution = signal;
        }];
    });

    it(@"should send execution signals", ^{
        expect([[command execute:@1] asynchronouslyWaitUntilCompleted:NULL]).to.beTruthy();

        expect(execution).notTo.beNil();
        expect([execution toArray]).to.equal((@[ @1, @2 ]));
    });

    it(@"should forward errors on execution signals", ^{
        shouldError = YES;

        __block NSError *error = nil;
        expect([[command execute:@1] asynchronouslyWaitUntilCompleted:&error]).to.beFalsy();
        expect(error).to.equal(testError);

        expect(execution).notTo.beNil();
        expect([execution waitUntilCompleted:&error]).to.beFalsy();
        expect(error).to.equal(testError);
    });
});

describe(@"-act_values", ^{
    it(@"should send values as they occur", ^{
        NSMutableArray *values = [NSMutableArray array];
        [command.act_values subscribeNext:^(id value) {
            [values addObject:value];
        }];

        expect([[command execute:@2] asynchronouslyWaitUntilCompleted:NULL]).to.beTruthy();
        expect(values).to.equal((@[ @2, @4 ]));
    });

    describe(@"disposal", ^{
        beforeEach(^{
            command = [[RACCommand alloc] initWithSignalBlock:^(NSNumber *input) {
                return [RACSignal return:input];
            }];
        });

        it(@"should deallocate values after they are sent", ^{
            RACSignal *willDealloc;

            @autoreleasepool{
                NSError *error;
                NSObject *value = [[NSObject alloc] init];
                willDealloc = value.rac_willDeallocSignal;

                BOOL success = [[command execute:value] asynchronouslyWaitUntilCompleted:&error];
                expect(success).to.beTruthy();
                expect(error).to.beNil();
            }

            expect([willDealloc asynchronouslyWaitUntilCompleted:NULL]).to.beTruthy();
        });
    });
});

describe(@"-act_nextExecution", ^{
    it(@"should forward next execution", ^{
        NSMutableArray *values = [NSMutableArray array];
        [command.act_nextExecution subscribeNext:^(id value) {
            [values addObject:value];
        }];
        
        expect([[command execute:@2] asynchronouslyWaitUntilCompleted:NULL]).to.beTruthy();
        expect(values).to.equal((@[ @2, @4 ]));
    });

    it(@"should send errors from execution", ^{
        __block NSError *receivedError = nil;
        [command.act_nextExecution subscribeError:^(NSError *error) {
            receivedError = error;
        }];
        
        shouldError = YES;
        expect([[command execute:@2] asynchronouslyWaitUntilCompleted:NULL]).to.beFalsy();
        expect(receivedError).to.equal(testError);
    });

    it(@"should replay last execution", ^{
        // The latest execution is replayed starting when it is first invoked.
        RACSignal *latestExecution = command.act_nextExecution;

        expect([[command execute:@2] asynchronouslyWaitUntilCompleted:NULL]).to.beTruthy();
        expect([latestExecution toArray]).to.equal((@[ @2, @4 ]));
    });
});

SpecEnd
