//
//  SwiftTransportBuilder.swift
//
//
//  Created by Mafalda on 2/19/24.
//

import Foundation

import Gardener
import Stencil

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
    
    func buildNewTransport(toneburstFile: URL) throws
    {
        try buildProjectStructure(projectDirectory: projectDirectory)
        try addStandardFiles()
        try addTransportFiles(toneburstFile: toneburstFile)
    }
    
    func buildNewTransport(toneburst: ToneBurstTemplate) throws
    {
        try buildProjectStructure(projectDirectory: projectDirectory)
        try addStandardFiles()
        try add(toneburst: toneburst)
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
    
    func addStandardFiles() throws
    {
        try updatePackageFile()
//        try updateTests()
        try addReadme(projectDirectory: projectDirectory, transportName: transportName)
    }
    
    /// Adds the transport specific files to the project
    func addTransportFiles(toneburstFile: URL) throws
    {
        let transportFileName = transportName + Extensions.dotSwift.rawValue
        addEmptySwiftFile(name: transportFileName)
        
        let configFileName = transportName + Constants.Files.configSwiftFileName
        try addConfigFile(filename: configFileName)
        
        try add(toneburstFile: toneburstFile)
    }
    
    /// Adds the transport specific files to the project
    func addTransportFiles(toneburst: ToneBurstTemplate) throws
    {
        let transportFileName = transportName + Extensions.dotSwift.rawValue
        addEmptySwiftFile(name: transportFileName)
        
        let configFileName = transportName + Constants.Files.configSwiftFileName
        try addConfigFile(filename: configFileName)
        
        try add(toneburst: toneburst)
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
            throw TransportBuilderError.failedToSaveFile(filePath: filePath)
        }
    }
    
    func add(toneburstFile fileURL: URL) throws
    {
        guard let fileContents = FileManager.default.contents(atPath: fileURL.path) else
        {
            throw TransportBuilderError.failedToFindFile(filePath: fileURL.path)
        }
        
        let savePath = sourcesDirectory.appendingPathComponent(fileURL.lastPathComponent, isDirectory: false).path
        guard FileManager.default.createFile(atPath: savePath, contents: fileContents.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: savePath)
        }
    }
    
    func add(toneburst: ToneBurstTemplate, saveDirectory: URL? = nil) throws -> String
    {
        let rendered = try ToneBurstTemplate.create(toneburst: toneburst)
        let savePath: String
        
        if let userURL = saveDirectory
        {
            savePath = userURL.appendingPathComponent(toneburst.name + Extensions.dotSwift.rawValue, isDirectory: false).path
        }
        else
        {
            savePath = sourcesDirectory.appendingPathComponent(toneburst.name + Extensions.dotSwift.rawValue, isDirectory: false).path
        }
        
        guard FileManager.default.createFile(atPath: savePath, contents: rendered.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: savePath)
        }
        
        return savePath
    }
    
    
    
}


