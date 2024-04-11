//
//  ConfigBuilder.swift
//
//
//  Created by Dr. Brandon Wiley on 4/11/24.
//

import Foundation

import Gardener
import Text

public struct ConfigBuilder
{
    public func build(command commandName: Text) throws -> GardenerBuilderConfig
    {
        let subcommandNames = try self.findSubcommands(commandName)
        let subcommands = subcommandNames.compactMap
        {
            subcommandName in

            do
            {
                return try self.makeSubcommand(commandName, subcommandName)
            }
            catch
            {
                return nil
            }
        }

        return GardenerBuilderConfig(command: commandName, subcommands: subcommands)
    }

    func findSubcommands(_ commandName: Text) throws -> [Text]
    {
        let command = Command()

        // Run the command with the "help" subcommand to get the list of other subcommands
        guard let (_, stdout, _) = command.run(commandName.string, "help") else
        {
            throw ConfigBuilderError.commandNotFound
        }

        return stdout.text.lines().compactMap
        {
            line in

            guard line.startsWith(" ") else
            {
                return nil
            }

            do
            {
                let (head, _) = try line.trim().splitOn(" ")
                return head
            }
            catch
            {
                return nil
            }
        }
    }

    func makeSubcommand(_ commandName: Text, _ subcommandName: Text) throws -> GardenerBuilderSubcommand
    {
        let command = Command()

        guard let (_, stdout, _) = command.run(commandName.string, "help", subcommandName.string) else
        {
            throw ConfigBuilderError.commandNotFound
        }

        let arguments = try self.findArguments(stdout.text)
        let options = try self.findOptions(stdout.text)

        return GardenerBuilderSubcommand(name: subcommandName, arguments: arguments, options: options)
    }

    func findArguments(_ text: Text) throws -> [GardenerBuilderArgument]
    {
        let lines = text.lines()

        let maybeUsage = lines.first
        {
            line in

            return line.lowercase().trim().startsWith("usage:")
        }

        // Extract arguments from "USAGE:" line, which could also be spelled "Usage:"
        if let usage = maybeUsage
        {
            return try usage.dropPrefix("usage:").split(" ").map
            {
                argumentName in

                if argumentName.surroundedBy("<", ">")
                {
                    // Optional arguments are written "<option>"

                    return GardenerBuilderArgument(name: try argumentName.dropSurrounding("<", ">"), optional: true)
                }
                else
                {
                    // Non-optional arguments are written "option"

                    return GardenerBuilderArgument(name: argumentName, optional: false)
                }
            }
        }
        else
        {
            return []
        }
    }

    func findOptions(_ text: Text) throws -> [Text]
    {
        let lines = text.lines()

        return lines.compactMap
        {
            subline in

            let trimmed = subline.trim()

            guard trimmed.startsWith("-") else
            {
                return nil
            }

            if trimmed.startsWith("--")
            {
                // Long option

                guard let (head, _) = try? trimmed.dropPrefix("--").splitOn(" ") else
                {
                    return nil
                }

                return head
            }
            else
            {
                // Short option

                guard let (_, tail) = try? trimmed.splitOn(",") else
                {
                    return nil
                }

                guard tail.startsWith("--") else
                {
                    return nil
                }

                guard let (head, _) = try? tail.dropPrefix("--").splitOn(" ") else
                {
                    return nil
                }

                return head
            }
        }
    }
}

public enum ConfigBuilderError: Error
{
    case commandNotFound
}
