//
//  RACCommand+Action.h
//  RACAction
//
//  Created by Justin Spahr-Summers on 2015-05-21.
//  Copyright (c) 2015 Automatic. All rights reserved.
//

@import ReactiveCocoa;

/// Extends RACCommand with methods like those of Action from the RAC 3.0 Swift
/// API.
///
/// NOTE: These methods require that the command be serial
/// (allowsConcurrentExecution set to NO).
@interface RACCommand (Action)

/// A signal of inner signals representing each execution of this command.
///
/// Unlike -[RACCommand executionSignals], the inner signals here may error out.
@property (nonatomic, strong, readonly) RACSignal *act_executions;

/// The values sent by all executions of this command.
///
/// This signal will never error, and will complete when the command is
/// deallocated.
@property (nonatomic, strong, readonly) RACSignal *act_values;

@end
