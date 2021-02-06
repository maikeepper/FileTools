//
//  LineReader.swift
//  PasswortDB
//
//  Created by Maike Epper on 30.01.21.
//

import Combine
import Foundation

public struct LineReader {
    public enum Error: Swift.Error {
        case cannotReadFile(URL)
    }

    private let subject = PassthroughSubject<String, LineReader.Error>()

    public var linePublisher: AnyPublisher<String, LineReader.Error> {
        return subject.eraseToAnyPublisher()
    }

    public func read(url: URL, lines linesToRead: Int? = nil) {
        guard let filePointer: UnsafeMutablePointer<FILE> = fopen(url.path, "r") else {
            subject.send(completion: .failure(.cannotReadFile(url)))
            return
        }

        var buffer: UnsafeMutablePointer<CChar>? = nil
        var cap: Int = 0
        var bytesRead = getline(&buffer, &cap, filePointer)
        
        defer {
            fclose(filePointer)
        }
        
        var readLines = 0
        while bytesRead > 0 {
            if linesToRead == readLines {
                break
            }
            let lineStr = String.init(cString: buffer!).trimmingCharacters(in: .newlines)
            subject.send(lineStr)
            bytesRead = getline(&buffer, &cap, filePointer)
            readLines += 1
        }
        subject.send(completion: .finished)
    }
}
