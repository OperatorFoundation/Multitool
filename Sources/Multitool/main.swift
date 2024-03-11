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
        @Argument(help: "The name of the new transport")
        var name: String

        @Argument(help: "Destination directory path")
        var projectDirectory: String
        
        @Option(name: .customLong("toneburst"), help: "The location of the pre-rendered Toneburst file")
        var toneburstPath: String

        mutating public func run() throws
        {
            let swiftBuilder = try SwiftTransportBuilder(projectDirectory: projectDirectory, transportName: name)
            
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
