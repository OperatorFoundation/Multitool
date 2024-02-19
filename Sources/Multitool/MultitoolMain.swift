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
        var output: String

        mutating public func run() throws
        {
            let outputURL = URL(fileURLWithPath: output)
            guard File.makeDirectory(url: outputURL) else
            {
                print("Creation of project directory failed")
                return
            }

            guard let swift = Swift() else
            {
                print("")
            }

            swift?.cd(output)
        }
    }
}

extension CommandLine
{
    struct CLI: ParsableCommand
    {
    }
}
