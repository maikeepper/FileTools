//
//  LineReader.swift
//
//  Created by Maike Epper on 30.01.21.
//

import Foundation
import Combine

class LinePublisherSubscription<S: Subscriber>: Subscription where S.Input == String, S.Failure == LinePublisher.Error {
    let url: URL
    let linesToRead: Int?

    var subscriber: S?
    var openDemand = Subscribers.Demand.none

    var filePointer: UnsafeMutablePointer<FILE>? = nil
    var buffer: UnsafeMutablePointer<CChar>? = nil
    var cap: Int = 0
    var readLines = 0


    init(url: URL, linesToRead: Int?, subscriber: S) {
        self.url = url
        self.linesToRead = linesToRead
        self.subscriber = subscriber
        self.filePointer = fopen(url.path, "r")
    }

    func request(_ demand: Subscribers.Demand) {
        openDemand += demand

        if openDemand > 0 && filePointer == nil {
            subscriber?.receive(completion: .failure(.cannotReadFile(url)))
            cancel()
            return
        }

        while openDemand > 0 {
            if readLines == linesToRead {
                subscriber?.receive(completion: .finished)
                cancel()
                return
            }

            guard let line = obtainLine() else {
                subscriber?.receive(completion: .finished)
                cancel()
                return
            }

            if let newDemand = subscriber?.receive(line) {
                openDemand += newDemand
            }

            readLines += 1
            openDemand -= 1
        }
    }

    private func obtainLine() -> String? {
        if getline(&buffer, &cap, filePointer) > 0 {
            return String(cString: buffer!).trimmingCharacters(in: .newlines)
        } else {
            return nil
        }
    }

    func cancel() {
        subscriber = nil
        if let _ = filePointer {
            fclose(filePointer)
        }
    }
}


public struct LinePublisher: Publisher {
    public enum Error: Swift.Error {
        case cannotReadFile(URL)
    }

    let url: URL
    let linesToRead: Int?

    public init(url: URL, linesToRead: Int?) {
        self.url = url
        self.linesToRead = linesToRead
    }

    public typealias Output = String
    public typealias Failure = LinePublisher.Error

    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = LinePublisherSubscription(url: url, linesToRead: linesToRead, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}


public extension URL {
    func linePublisher(lines linesToRead: Int? = nil) -> LinePublisher {
        return LinePublisher(url: self, linesToRead: linesToRead)
    }
}
