//
//  RACCommand+RACAction.h
//  RACAction
//
//  Created by Eric Horacek on 9/14/15.
//  Copyright (c) 2015 Automatic. All rights reserved.
//

@import ReactiveCocoa;

/// Extends RACCommand with methods like those of Action from the RAC 3.0 Swift
/// API.
@interface RACCommand (RACAction)

/// A signal of inner signals representing each execution of this action.
///
/// The receiver must have allowsConcurrentExecution set to YES to invoke this
/// getter. If not enabled, an exception will be thrown.
///
/// Unlike -[RACCommand executionSignals], the inner signals here may error out.
@property (nonatomic, strong, readonly) RACSignal *act_executions;

/// The values sent by all executions of this action.
///
/// This signal will never error, and will complete when the action is
/// deallocated.
@property (nonatomic, strong, readonly) RACSignal *act_values;

/// Replays the latest inner signal sent upon -act_executions following the
/// invocation of this getter, including any error or completed event.
///
/// Different subscriptions to this signal may connect to different executions
/// of the action.
///
/// Returns a signal that, upon subscription, will replay events from any
/// executions following the invocation of this getter, then forward any future
/// events, or else the previous execution if the action is not currently
/// executing.
@property (nonatomic, strong, readonly) RACSignal *act_latestExecution;

@end
