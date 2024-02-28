//
//  Errors.swift
//
//
//  Created by Mafalda on 2/19/24.
//

import Foundation


public enum TransportBuilderError: Error, CustomStringConvertible
{
    case swiftEnvironmentCreationFailure
    case projectDirectoryCreationFailure
    case directoryNavigation(directoryPath: String)
    case projectCreationFailure
    case templateFileNotFound(filename: String)
    case unimplemented
    
    public var description: String
    {
        switch self {
            case .swiftEnvironmentCreationFailure:
                return "Internal error setting up the Swift environment."
            case .projectDirectoryCreationFailure:
                return "Creation of project directory failed."
            case .unimplemented:
                return "Unimplemented code! 😅"
            case .directoryNavigation(directoryPath: let directoryPath):
                return "Unable to navigate to a directory: \(directoryPath)"
            case .projectCreationFailure:
                return "Failed to initialize a new Swift Package."
            case.templateFileNotFound(filename: let filename):
                return "Failed to find the template \(filename). The resulting file needed for this project could not be generated."
        }
    }
}
