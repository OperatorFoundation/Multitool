//
//  SwiftTransportBuilder.swift
//
//
//  Created by Mafalda on 2/19/24.
//

import Foundation

import Gardener

struct SwiftTransportBuilder
{
    let swift: SwiftTool
    let projectDirectory: String
    let transportName: String
    
    init(projectDirectory: String, transportName: String) throws
    {
        guard let newSwift: SwiftTool = SwiftTool() else
        {
            throw TransportBuilderError.swiftEnvironmentCreationFailure
        }
        
        self.swift = newSwift
        self.projectDirectory = projectDirectory
        self.transportName = transportName
    }
    
    func buildNewTransport() throws
    {
        let projectDirectoryURL = URL(fileURLWithPath: projectDirectory)
        try buildProjectStructure(projectDirectory: projectDirectoryURL)
//        try addTransportFiles()
//        try updatePackageFile()
//        try updateTests()
        try addReadme(projectDirectory: projectDirectoryURL, transportName: transportName)
    }
    
    /// Uses swift commands to create a new Swift Package library
    func buildProjectStructure(projectDirectory: URL) throws
    {
        // Make the project directory
        
        guard File.makeDirectory(url: projectDirectory) else
        {
            throw TransportBuilderError.projectDirectoryCreationFailure
        }

        guard swift.cd(projectDirectory.path) else
        {
            throw TransportBuilderError.directoryNavigation(directoryPath: projectDirectory.path)
        }
        
        // Create the basic swift package project
        guard let createPackageResult = swift.initialize() else
        {
            throw TransportBuilderError.projectCreationFailure
        }
    }
    
    // TODO: Implement addTransportFiles
    /// Adds the transport specific files to the project
    func addTransportFiles() throws
    {
        throw TransportBuilderError.unimplemented
    }
    
    // TODO: Implement updatePackageFile
    /// Updates the Package.swift file for the new transport project
    func updatePackageFile() throws
    {
        throw TransportBuilderError.unimplemented
    }
    
    // TODO: Implement updateTests
    /// Updates the swift test file to have test functions for the code generated here
    func updateTests() throws
    {
        throw TransportBuilderError.unimplemented
    }
    
    // TODO: Implement addReadme
    // This is markdown and not swift specific
    // We should consider moving this to a more general purpose location in the future
    func addReadme(projectDirectory: URL, transportName: String) throws
    {
        let titleLine = "# \(transportName)"
        let descriptionLine = "**\(transportName)** is a Swift transport library which can be integrated directly into applications."
        let contents = [titleLine, descriptionLine, Constants.Files.Readme.transportsDescription]
        let contentString: String = contents.joined(separator: "\n\n")
        
        FileManager.default.createFile(atPath: projectDirectory.appending(path: Constants.Files.Readme.name, directoryHint: .notDirectory).path, contents: contentString.data)
        
    }
    
}


