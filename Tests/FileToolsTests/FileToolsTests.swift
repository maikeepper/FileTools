import Combine
import XCTest
@testable import FileTools

final class FileToolsTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        cancellables = []
    }
    
    func testLineReader() {
        // expectation
        let expectation = XCTestExpectation(description: "all lines are equal")

        // given
        let testStringPublisher = [
            "Das ist",
            "",
            "ein",
            "Test",
            ""
        ].publisher
        let lineReader = LineReader()
        
        lineReader.linePublisher
            .print()
            .catch { _ in
                Just("too bad")
            }
            .zip(testStringPublisher)
            .sink(
            receiveCompletion: { completion in
                XCTAssertTrue(completion == .finished)
                expectation.fulfill()
            },
            receiveValue: { lineFromFile, lineFromString in
                XCTAssertTrue(lineFromFile == lineFromString, "\(lineFromFile) != \(lineFromString)")
            })
            .store(in: &cancellables)
        
        // when ;-) -> async then
        lineReader.read(from: Bundle.module.url(forResource: "testfile", withExtension: "txt")!.path)
        wait(for: [expectation], timeout: 5.0)
    }

    static var allTests = [
        ("testLineReader", testLineReader)
    ]
}
