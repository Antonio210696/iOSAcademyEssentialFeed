//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 04/05/23.
//

import Combine
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
	private let decoratee: T
	
	init(decoratee: T) {
		self.decoratee = decoratee
	}
	
	func dispatch(completion: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { completion() }
		}
		
		completion()
	}
}

extension Publisher {
	func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
		receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
	}
}

extension DispatchQueue {
	
	static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
		ImmediateWhenOnMainQueueScheduler()
	}
	
	struct ImmediateWhenOnMainQueueScheduler: Scheduler {
		typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
		typealias SchedulerOptions = DispatchQueue.SchedulerOptions
		
		var now: SchedulerTimeType {
			DispatchQueue.main.now
		}
		
		var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
			DispatchQueue.main.minimumTolerance
		}
		
		func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
			guard Thread.isMainThread else {
				return DispatchQueue.main.schedule(options: options, action)
			}
			
			action()
		}
		
		func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
			DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
		}
		
		func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
			DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
		}
	}
}
