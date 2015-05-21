//
//  RACAction.h
//  RACAction
//
//  Created by Justin Spahr-Summers on 2015-05-21.
//  Copyright (c) 2015 Automatic. All rights reserved.
//

@import ReactiveCocoa;

//! Project version number for RACAction.
FOUNDATION_EXPORT double RACActionVersionNumber;

//! Project version string for RACAction.
FOUNDATION_EXPORT const unsigned char RACActionVersionString[];

/// Extends RACCommand with methods like those of Action from the RAC 3.0 Swift
/// API.
@interface RACAction : RACCommand

/// A signal of inner signals representing each execution of this action.
///
/// Unlike -[RACCommand executionSignals], the inner signals here may error out.
@property (nonatomic, strong, readonly) RACSignal *act_executions;

/// The values sent by all executions of this action.
///
/// This signal will never error, and will complete when the action is
/// deallocated.
@property (nonatomic, strong, readonly) RACSignal *act_values;

/// Replays the latest inner signal sent upon -act_executions, including any
/// error or completed event.
///
/// Different subscriptions to this signal may connect to different executions
/// of the action.
///
/// Returns a signal that, upon subscription, will replay events from the
/// current execution so far, then forward any future events, or else the
/// previous execution if the action is not currently executing.
@property (nonatomic, strong, readonly) RACSignal *act_latestExecution;

@property (atomic, assign) BOOL allowsConcurrentExecution __attribute__((unavailable("RACActions are required to be serial")));
@property (nonatomic, strong, readonly) RACSignal *executionSignals __attribute__((unavailable("Use -act_executions instead")));

@end
