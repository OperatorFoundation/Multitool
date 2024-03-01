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
    let projectDirectory: URL
    let sourcesDirectory: URL
    let transportName: String
    
    
    init(projectDirectory: String, transportName: String) throws
    {
        guard let newSwift: SwiftTool = SwiftTool() else
        {
            throw TransportBuilderError.swiftEnvironmentCreationFailure
        }
        
        self.swift = newSwift
        self.transportName = transportName
        self.projectDirectory = URL(fileURLWithPath: projectDirectory).appendingPathComponent(transportName, isDirectory: true)
        self.sourcesDirectory = self.projectDirectory.appendingPathComponent("\(Constants.Directories.sources)/\(transportName)/", isDirectory: true)
    }
    
    func buildNewTransport() throws
    {
        try buildProjectStructure(projectDirectory: projectDirectory)
        try addTransportFiles()
        try updatePackageFile()
//        try updateTests()
        try addReadme(projectDirectory: projectDirectory, transportName: transportName)
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
        guard let _ = swift.initialize() else
        {
            throw TransportBuilderError.projectCreationFailure
        }
    }
    
    // TODO: Implement addTransportFiles
    /// Adds the transport specific files to the project
    func addTransportFiles() throws
    {
        let transportFileName = transportName + Extensions.dotSwift.rawValue
        addEmptySwiftFile(name: transportFileName)
        
        let configFileName = transportName + Constants.Files.configSwiftFileName
        try addConfigFile(filename: configFileName)
        
    }
    
    /// Updates the Package.swift file for the new transport project
    func updatePackageFile() throws
    {
        let packageContents = try buildPackageFile()
        let packageURL = projectDirectory.appendingPathComponent(Templates.PackageWithExtension.rawValue, isDirectory: false)
        FileManager.default.createFile(atPath: packageURL.path, contents: packageContents.data)
    }
    
    // TODO: Implement updateTests
    /// Updates the swift test file to have test functions for the code generated here
    func updateTests() throws
    {
        throw TransportBuilderError.unimplemented
    }
    
    // This is markdown and not swift specific
    // TODO: We should consider moving this to a more general purpose location in the future
    func addReadme(projectDirectory: URL, transportName: String) throws
    {
        let titleLine = "# \(transportName)"
        let descriptionLine = "**\(transportName)** is a Swift transport library which can be integrated directly into applications."
        let contents = [titleLine, descriptionLine, Constants.Files.Readme.transportsDescription]
        let contentString: String = contents.joined(separator: "\n\n")
        
        FileManager.default.createFile(atPath: projectDirectory.appending(path: Constants.Files.Readme.name, directoryHint: .notDirectory).path, contents: contentString.data)
        
    }
    
    /// Adds a swift file to the directory provided, or the Sources directory if none is provided
    func addEmptySwiftFile(name: String, directory: String? = nil)
    {
        let headerString = """
        //
        // \(name)
        //
        // \(Date())
        //
        """
        
        let filePath = directory ?? sourcesDirectory.appending(path: name, directoryHint: .isDirectory).path
        
        FileManager.default.createFile(atPath: filePath, contents: headerString.data)
    }
    
    func buildPackageFile() throws -> String
    {
        guard let fileURL = Bundle.module.url(forResource: Templates.Package.rawValue, withExtension: Extensions.txt.rawValue) else
        {
            throw TransportBuilderError.templateFileNotFound(filename: Templates.Package.rawValue)
        }
        
        print("Package file template found.")
        
        var fileContents = try String(contentsOf: fileURL)
        fileContents = fileContents.replacingOccurrences(of: Constants.placeholderTransportName, with: transportName)
        return fileContents
    }
    
    func buildConfigFile() throws -> String
    {
        guard let fileURL = Bundle.module.url(forResource: Templates.NOMNIConfig.rawValue, withExtension: Extensions.txt.rawValue) else
        {
            throw TransportBuilderError.templateFileNotFound(filename: Templates.NOMNIConfig.rawValue)
        }
        
        // we found the file in our bundle!
        print("NOMNIConfig template found at: \(fileURL.path)")
        var fileContents = try String(contentsOf: fileURL)
        fileContents = fileContents.replacingOccurrences(of: Constants.placeholderTransportName, with: transportName)
        return fileContents
    }
    
    func addConfigFile(filename: String) throws
    {
        let fileContents = try buildConfigFile()
        let filePath = sourcesDirectory.appendingPathComponent(filename, isDirectory: false).path
        guard FileManager.default.createFile(atPath: filePath, contents: fileContents.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: sourcesDirectory.path)
        }
    }
    
}


