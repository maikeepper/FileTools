import Combine
import XCTest
@testable import FileTools

final class FileToolsTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        cancellables = []
    }
    
    func testLineReader() {
        let allLinesEqual = expectation(description: "all lines are equal")

        let testfile = Bundle.module.url(forResource: "testfile", withExtension: "txt")!
        testfile.linePublisher()
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

        waitForExpectations(timeout: 1, handler: nil)
    }

//    func testLinesToRead() {
//        // given
//        let numberOfLinesToRead = 3
//        let threeLinesRead = expectation(description: "3 lines read")
//
//        let lineReader = LineReader()
//        lineReader.linePublisher
//            .catch { _ in
//                Just(String())
//            }
//            .collect(3)
//            .sink(
//                receiveCompletion: { completion in
//                    XCTAssertTrue(completion == .finished)
//                    threeLinesRead.fulfill()
//                },
//                receiveValue: { threeLines in
//                    XCTAssertTrue(threeLines.count == numberOfLinesToRead, "Not the right amount of numbers read")
//                }
//            ).store(in: &cancellables)
//
//        // when
//        let testdata = Bundle.module.url(forResource: "testfile", withExtension: "txt")!
//        lineReader.read(url: testdata, lines: numberOfLinesToRead)
//
//        // then
//        waitForExpectations(timeout: 1, handler: nil)
//    }
//
//    func testSpeedHugeFile() {
//        // given
//        let hugeFileRead = expectation(description: "Huge file read")
//
//        let lineReader = LineReader()
//        lineReader.linePublisher
//            .catch { _ in
//                Just(String())
//            }
//            .sink(
//                receiveCompletion: { completion in
//                    XCTAssertTrue(completion == .finished)
//                    hugeFileRead.fulfill()
//                },
//                receiveValue: { _ in }
//            ).store(in: &cancellables)
//
//        // when
//        let rockyou = Bundle.module.url(forResource: "rockyou_500_000", withExtension: "txt")!
//        measure {
//            lineReader.read(url: rockyou, lines: 500_000)
//        }
//
//        // then
//        waitForExpectations(timeout: 1, handler: nil)
//    }
//
//    func testMultipleReads() {
//        let numberOfReads = 2
//        assert(numberOfReads > 1)
//
//        let read = expectation(description: "read not executed")
//        read.expectedFulfillmentCount = numberOfReads
//
//        let lineReader = LineReader()
//        lineReader.linePublisher
//            .catch { _ in
//                Just(String())
//            }
//            .sink(
//                receiveCompletion: { _ in },
//                receiveValue: { _ in
//                    read.fulfill()
//                }
//            ).store(in: &cancellables)
//
//        // when
//        let testfile = Bundle.module.url(forResource: "testfile", withExtension: "txt")!
//        (0..<numberOfReads).forEach { _ in
//            lineReader.read(url: testfile, lines: 1)
//        }
//
//        // then
//        waitForExpectations(timeout: 1, handler: nil)
//    }
}
