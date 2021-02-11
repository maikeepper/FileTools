# FileTools

Swift file helper collection

## Installation

In your Xcode project add `https://github.com/maikeepper/FileTools` as Swift package dependency.

When you package your project, add this to your Package.swift manifest:

    dependencies: [
        .package(url: "https://github.com/maikeepper/FileTools.git", branch: "main")
    ]

## Usage LinePublisher

    import FileTools

Subscribe to read the file line by line

    Bundle.main.url(forResource: <your-ressource>, withExtension: <your-ressource-extension>)!
        .linePublisher()
        .catch { _ in
            Just(String())
        }
        .sink(
            receiveCompletion: { completion in
                ...
            },
            receiveValue: { line in
                ...
            })
        .store(in: &cancellables)

Subscribe to read the file in blocks of 10 lines each:

    Bundle.main.url(forResource: <your-ressource>, withExtension: <your-ressource-extension>)!
        .linePublisher()
        .collect(10) // optional: read 10 lines at once
        .sink(
            receiveValue: { 10lines in
                10lines.foreach { line in
                    ...
                }
            }
        )

Subscribe to read the first 25 lines of a file:

    Bundle.main.url(forResource: <your-ressource>, withExtension: <your-ressource-extension>)!
        .linePublisher(lines: 25)
        .sink(
            receiveCompletion: { completion in
                ...
            },
            receiveValue: { line in
                ...
            })
