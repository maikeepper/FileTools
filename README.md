# FileTools

Swift file helper collection

## Installation

Check out the project and drag the package into your Xcode project. In your .xcodeproj file it should be added to the "Frameworks ..." section.

## Usage

import FileTools

let lineReader = LineReader()
lineReader.publisher.sink(
    receiveValue: { lines in
        ...
    }
)

lineReader.read(from: path)
