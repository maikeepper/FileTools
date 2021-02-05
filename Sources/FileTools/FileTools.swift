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
        case cannotReadFile(String)
    }

    private let subject = PassthroughSubject<String, LineReader.Error>()
    public var linePublisher: AnyPublisher<String, LineReader.Error> {
        return subject.eraseToAnyPublisher()
    }
    
    public init() {}
    
    public func read(from url: String, lines linesToRead: Int? = nil) {
        guard let filePointer: UnsafeMutablePointer<FILE> = fopen(url, "r") else {
            subject.send(completion: .failure(.cannotReadFile(url)))
            return
        }
        
        // if linesToRead < 0 { linesPointer = endOfFile } && readLines -= 1
        var linesPointer: UnsafeMutablePointer<CChar>? = nil
        var lineCap: Int = 0
        var bytesRead = getline(&linesPointer, &lineCap, filePointer)
        
        defer {
            fclose(filePointer)
        }
        
        var readLines = 0
        while bytesRead > 0 {
            if linesToRead == readLines {
                break
            }
            let lineStr = String.init(cString: linesPointer!).trimmingCharacters(in: .newlines)
            subject.send(lineStr)
            bytesRead = getline(&linesPointer, &lineCap, filePointer)
            readLines += 1
        }
        subject.send(completion: .finished)
    }
}
