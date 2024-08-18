//
//  AsyncStream-Extension.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

extension AsyncStream {
    
    static func makeStream(of elementType: Element.Type = Element.self, bufferingPolicy limit: Continuation.BufferingPolicy = .unbounded) -> (stream: AsyncStream<Element>, continuation: AsyncStream<Element>.Continuation) {
        var continuation: AsyncStream<Element>.Continuation!
        let stream = AsyncStream<Element>(bufferingPolicy: limit) { continuation = $0 }
        return (stream: stream, continuation: continuation!)
    }
    
}
