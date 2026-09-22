//
//  PassthroughPublisher.swift
//  iPhoneDuoSample
//
//  Created by Marcel Piešťanský on 09/22/2026.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Combine
import Foundation

@propertyWrapper
public struct PassthroughPublisher<Output, Failure> where Failure: Swift.Error {
    public var wrappedValue: AnyPublisher<Output, Failure>
    
    private let subject: PassthroughSubject<Output, Failure> = .init()
    
    public init() {
        wrappedValue = subject
            .eraseToAnyPublisher()
    }
    
    public init(on queue: DispatchQueue) {
        wrappedValue = subject
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    public func callAsFunction(_ input: Output, completesImmediately: Bool = false) {
        send(input)
        
        if completesImmediately {
            send(completion: .finished)
        }
    }
    
    public func send(_ value: Output) {
        subject.send(value)
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        subject.send(completion: completion)
    }
    
    public func send(_ value: Output, with completion: Subscribers.Completion<Failure>) {
        send(value)
        send(completion: completion)
    }
    
    public func callAsFunction(failure: Failure) {
        send(completion: .failure(failure))
    }
}

public extension PassthroughPublisher where Output == Void {
    func send() {
        subject.send(())
    }
    
    func callAsFunction() {
        send()
    }
    
    func callAsFunction(completesImmediately: Bool) {
        callAsFunction()
        
        if completesImmediately {
            send(completion: .finished)
        }
    }
}
