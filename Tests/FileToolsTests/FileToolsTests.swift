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
        let allLinesEqual = expectation(description: "all lines are equal")

        // given
        let lineReader = LineReader()
        
        lineReader.linePublisher
            .print()
            .catch { _ in
                Just(String())
            }
            .zip(["Das ist","","ein","Test",""].publisher)
            .sink(
            receiveCompletion: { completion in
                XCTAssertTrue(completion == .finished)
                allLinesEqual.fulfill()
            },
            receiveValue: { publishedFromLineReader, other in
                XCTAssert(publishedFromLineReader == other, #"Strings "\#(publishedFromLineReader)" and "\#(other)" are not equal."#)
            })
            .store(in: &cancellables)
        
        // when ;-) -> async then
        let testfile = Bundle.module.url(forResource: "testfile", withExtension: "txt")!
        lineReader.read(url: testfile)

        // then
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRead3Lines() {
        // given
        let numberOfLInesToRead = 3
        let threeLinesRead = expectation(description: "3 lines read")

        let lineReader = LineReader()
        lineReader.linePublisher
            .catch { _ in
                Just(String())
            }
            .collect(3)
            .sink(
                receiveCompletion: { completion in
                    XCTAssertTrue(completion == .finished)
                    threeLinesRead.fulfill()
                },
                receiveValue: { threeLines in
                    XCTAssertTrue(threeLines.count == numberOfLInesToRead, "Not the right amount of numbers read")
                }
            ).store(in: &cancellables)

        // when
        let testdata = Bundle.module.url(forResource: "testfile", withExtension: "txt")!
        lineReader.read(url: testdata, lines: numberOfLInesToRead)

        // then
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSpeedHugeFile() {
        // given
        let hugeFileRead = expectation(description: "Huge file read")

        let lineReader = LineReader()
        lineReader.linePublisher
            .catch { _ in
                Just(String())
            }
            .sink(
                receiveCompletion: { completion in
                    XCTAssertTrue(completion == .finished)
                    hugeFileRead.fulfill()
                },
                receiveValue: { _ in }
            ).store(in: &cancellables)

        // when
        let rockyou = Bundle.module.url(forResource: "rockyou_500_000", withExtension: "txt")!
        measure {
            lineReader.read(url: rockyou, lines: 500_000)
        }

        // then
        waitForExpectations(timeout: 1, handler: nil)
    }
}
