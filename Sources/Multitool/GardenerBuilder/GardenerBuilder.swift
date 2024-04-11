//
//  GardenerBuilder.swift
//  
//
//  Created by Dr. Brandon Wiley on 4/11/24.
//

import Foundation

import Gardener
import Stencil

public struct GardenerBuilder
{
    let outputPath: String
    let command: String

    init(saveDirectory: String, command: String) throws
    {
        self.command = command

        self.outputPath = URL(fileURLWithPath: saveDirectory).appendingPathComponent("\(try command.text.uppercaseFirstLetter())Command.swift").path
    }

    func build() throws
    {
        let configBuilder = ConfigBuilder()
        let config = try configBuilder.build(command: self.command.text)
        let rendered = try TemplateBuilder.create(context: config.dictionary, templateName: "GardenerCommand")

        guard FileManager.default.createFile(atPath: self.outputPath, contents: rendered.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: self.outputPath)
        }

        print("✒︎ \(try self.command.text.uppercaseFirstLetter())Command.swift saved.")
    }
}

public enum GardenerBuilderError: Error
{
}


