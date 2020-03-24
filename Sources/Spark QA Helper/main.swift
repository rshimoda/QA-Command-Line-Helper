#!/usr/bin/swift

import ArgumentParser

// MARK: -

struct SparkHelper: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "", subcommands: [GIFGeneration.self])

    init() { }
}

SparkHelper.main()
