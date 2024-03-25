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
        
        @Option(name: .customLong("toneburst"), help: "The location of the pre-rendered Toneburst file.")
        var toneburstPath: String
        
        @Option(name: .customLong("serverMode"), help: "The mode to use for handling the toneburst server.")
        var serverMode: String
        
        @Option(name: .customLong("clientMode"), help: "The mode to use for handling the toneburst client.")
        var clientMode: String
        
        @Option(name: .customLong("toneburstName"), help: "The name of the toneburst.")
        var toneburstName: String

        mutating public func run() throws
        {
            let swiftBuilder = try SwiftTransportBuilder(saveDirectory: saveDirectory, transportName: name, modes: [serverMode, clientMode], toneburstName: toneburstName)
            
            guard FileManager.default.fileExists(atPath: toneburstPath) else
            {
                throw TransportBuilderError.failedToFindFile(filePath: toneburstPath)
            }
            
            let toneburstURL = URL(fileURLWithPath: toneburstPath, isDirectory: false)
            
            try swiftBuilder.buildNewTransport(toneburstFile: toneburstURL)
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
