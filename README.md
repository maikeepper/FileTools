# FileTools

Swift file helper collection

## Installation

In your Xcode project add `https://github.com/maikeepper/FileTools` as Swift package dependency.

When you package your project, add this to your Package.swift manifest:

    dependencies: [
        .package(url: "https://github.com/maikeepper/FileTools.git", branch: "main")
    ]

## Usage LineReader

    import FileTools

Subscribe to read the file line by line

    let lineReader = LineReader()
    lineReader.linePublisher
        .sink(
            receiveValue: { line in
                ...
            }
        )

Subscribe to read the file in blocks of 10 lines each:

    let lineReader = LineReader()
    lineReader.linePublisher
        .collect(10) // optional: read 10 lines at once
        .sink(
            receiveValue: { 10lines in
                10lines.foreach { line in
                    ...
                }
            }
        )

After having defined your subscription, start reading

    lineReader.read(url: <Url>)


Alternatively, read only up to 25 lines

    lineReader.read(url: <Url>, lines: 25)
