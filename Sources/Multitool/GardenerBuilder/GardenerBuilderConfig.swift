//
//  GardenerBuilderConfig.swift
//
//
//  Created by Dr. Brandon Wiley on 4/11/24.
//

import Foundation

import Text

public struct GardenerBuilderConfig
{
    public let command: Text
    public let subcommands: [GardenerBuilderSubcommand]

    public var dictionary: [String: Any]
    {
        return [
            "command": self.command,
            "subcommands": self.subcommands.map {$0.dictionary}
        ]
    }

    public init(command: Text, subcommands: [GardenerBuilderSubcommand])
    {
        self.command = command
        self.subcommands = subcommands
    }
}

public struct GardenerBuilderSubcommand
{
    public let name: Text
    public let arguments: [GardenerBuilderArgument]
    public let options: [Text]

    public var dictionary: [String: Any]
    {
        return [
            "name": self.name,
            "arguments": self.arguments.map {$0.dictionary},
            "options": self.options
        ]
    }

    public init(name: Text, arguments: [GardenerBuilderArgument], options: [Text])
    {
        self.name = name
        self.arguments = arguments
        self.options = options
    }
}

public struct GardenerBuilderArgument
{
    public let name: Text
    public let optional: Bool

    public var dictionary: [String: Any]
    {
        return [
            "name": self.name,
            "optional": self.optional
        ]
    }

    public init(name: Text, optional: Bool)
    {
        self.name = name
        self.optional = optional
    }
}
