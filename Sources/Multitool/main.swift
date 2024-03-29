//
//  MultitoolMain.swift
//
//
//  Created by Dr. Brandon Wiley on 2/19/24.
//

import ArgumentParser
import Foundation

import Gardener

struct CommandLine: ParsableCommand
{
    static let configuration = CommandConfiguration(
        commandName: "multitool",
        subcommands: [Transport.self, CLI.self]
    )
}

extension CommandLine
{
    struct Transport: ParsableCommand
    {
        @Argument(help: "The name of the new transport.")
        var name: String

        @Option(name: .customLong("destination"), help: "Destination directory for the new Swift Package, and other generated files.")
        var saveDirectory: String
        
        @Option(name: .customLong("toneburst"), help: "The directory containing the Omni programs for generating the Toneburst file")
        var toneburstDirectory: String

        mutating public func run() throws
        {
            guard FileManager.default.fileExists(atPath: toneburstDirectory) else
            {
                throw TransportBuilderError.failedToFindFile(filePath: toneburstDirectory)
            }
            
            let toneburstURL = URL(fileURLWithPath: toneburstDirectory, isDirectory: false)
            
            let swiftBuilder = try SwiftTransportBuilder(saveDirectory: saveDirectory, transportName: name, toneburstDirectory: toneburstURL)
            
            try swiftBuilder.buildNewTransport()
        }

    }
}

extension CommandLine
{
    struct CLI: ParsableCommand
    {
    }
}

CommandLine.main()
