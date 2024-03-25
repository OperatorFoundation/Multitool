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
    let saveDirectory: URL
    let projectDirectory: URL
    let sourcesDirectory: URL
    let transportName: String
    let modes: [String]
    let toneburstName: String
    
    init(saveDirectory: String, transportName: String, modes: [String], toneburstName: String) throws
    {
        guard let newSwift: SwiftTool = SwiftTool() else
        {
            throw TransportBuilderError.swiftEnvironmentCreationFailure
        }
        
        self.swift = newSwift
        self.transportName = transportName
        self.saveDirectory = URL(fileURLWithPath: saveDirectory)
        self.projectDirectory = URL(fileURLWithPath: saveDirectory).appendingPathComponent(transportName, isDirectory: true)
        self.sourcesDirectory = self.projectDirectory.appendingPathComponent("\(Constants.Directories.sources)/\(transportName)/", isDirectory: true)
        self.modes = modes
        self.toneburstName = toneburstName
    }
    
    func buildNewTransport(toneburstFile: URL) throws
    {
        try buildProjectStructure(projectDirectory: projectDirectory)
        try addStandardFiles()
        try add(toneburstFile: toneburstFile)
    }
    
    func buildNewTransport(toneburst: ToneBurstTemplate) throws
    {
        try buildProjectStructure(projectDirectory: projectDirectory)
        try addStandardFiles()
        let _ = try add(toneburst: toneburst)
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
        try addPackageFile()

        try addReadme(projectDirectory: projectDirectory, transportName: self.transportName)
        
        let configFilename = self.transportName + Constants.Files.configSwiftFilename
        try addConfigFile(filename: configFilename)
        
        let errorFilename = self.transportName + Constants.Files.errorSwiftFilename
        try addErrorsFile(filename: errorFilename)
        
        let transportFilename = self.transportName + Extensions.dotSwift.rawValue
        try addTransportFile(filename: transportFilename, name: self.transportName, modes: self.modes, toneburstName: self.toneburstName)
        
        let dispatcherFilename = self.transportName + Constants.Files.dispatcherSwiftFilename
        try addDispatcherFile(filename: dispatcherFilename)
    }

    // TODO: Implement updateTests
    /// Updates the swift test file to have test functions for the code generated here
    func addTestFile() throws
    {
        throw TransportBuilderError.unimplemented
    }
    
    func buildTestFile() -> String
    {
        return ""
    }
    
    // This is markdown and not swift specific
    func addReadme(projectDirectory: URL, transportName: String) throws
    {
        let titleLine = "# \(transportName)"
        let descriptionLine = "**\(transportName)** is a Swift transport library which can be integrated directly into applications."
        let contents = [titleLine, descriptionLine, Constants.Files.Readme.transportsDescription]
        let contentString: String = contents.joined(separator: "\n\n")
        
        FileManager.default.createFile(atPath: projectDirectory.appending(path: Constants.Files.Readme.name, directoryHint: .notDirectory).path, contents: contentString.data)
        print("✒︎ \(transportName) README file saved.")
    }
    
    func addPackageFile() throws
    {
        let packageContents = try buildPackageFile()
        let packageURL = projectDirectory.appendingPathComponent(Templates.PackageWithExtension.rawValue, isDirectory: false)
        FileManager.default.createFile(atPath: packageURL.path, contents: packageContents.data)
        print("✒︎ \(transportName) Package.swift file saved.")
    }
    
    func buildPackageFile() throws -> String
    {
        // Try to find the template file in our bundle.
        guard let fileURL = Bundle.module.url(forResource: Templates.Package.rawValue, withExtension: Extensions.txt.rawValue) else
        {
            throw TransportBuilderError.templateFileNotFound(filename: Templates.Package.rawValue)
        }
        
        // We found the file, update the contents.
        var fileContents = try String(contentsOf: fileURL)
        fileContents = fileContents.replacingOccurrences(of: Constants.placeholderTransportName, with: transportName)
        print("✒︎ \(transportName) Package.swift file created.")
        return fileContents
    }
    
    func addConfigFile(filename: String) throws
    {
        let filePath = sourcesDirectory.appendingPathComponent(filename, isDirectory: false).path
        try addConfigFile(filePath: filePath)
    }
    
    func addConfigFile(filePath: String) throws
    {
        let fileContents = try buildConfigFile()
        
        guard FileManager.default.createFile(atPath: filePath, contents: fileContents.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: filePath)
        }
        print("✒︎ \(transportName) config file saved.")
    }
    
    func buildConfigFile() throws -> String
    {
        // Try to find the template file in our bundle.
        guard let fileURL = Bundle.module.url(forResource: Templates.NOMNIConfig.rawValue, withExtension: Extensions.txt.rawValue) else
        {
            throw TransportBuilderError.templateFileNotFound(filename: Templates.NOMNIConfig.rawValue)
        }
        
        // We found the file, update the contents.
        var fileContents = try String(contentsOf: fileURL)
        fileContents = fileContents.replacingOccurrences(of: Constants.placeholderTransportName, with: transportName)
        print("✒︎ \(transportName) config file created.")
        return fileContents
    }
    
    func addTransportFile(filename: String, name: String, modes: [String], toneburstName: String) throws
    {
        let fileContents = try TransportFactory.create(name: name, modes: modes, toneburstName: toneburstName)
        let filePath = sourcesDirectory.appendingPathComponent(filename, isDirectory: false).path
        guard FileManager.default.createFile(atPath: filePath, contents: fileContents.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: filePath)
        }
        print("✒︎ \(transportName) file saved.")
    }
    
    func addErrorsFile(filename: String) throws
    {
        let fileContents = try buildErrorsFile()
        let filePath = sourcesDirectory.appendingPathComponent(filename, isDirectory: false).path
        guard FileManager.default.createFile(atPath: filePath, contents: fileContents.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: filePath)
        }
        
        print("✒︎ \(transportName) error file saved.")
    }
    
    func buildErrorsFile() throws -> String
    {
        // Try to find the template file in our bundle.
        guard let fileURL = Bundle.module.url(forResource: Templates.NOMNIError.rawValue, withExtension: Extensions.txt.rawValue) else
        {
            throw TransportBuilderError.templateFileNotFound(filename: Templates.NOMNI.rawValue)
        }
        
        // We found the file, update the contents.
        var fileContents = try String(contentsOf: fileURL)
        fileContents = fileContents.replacingOccurrences(of: Constants.placeholderTransportName, with: transportName)
        print("✒︎ \(transportName) error file created.")
        return fileContents
    }
    
    func addDispatcherFile(filename: String) throws
    {
        let fileContents = try buildDispatcherFile()
        let filePath = saveDirectory.appendingPathComponent(filename, isDirectory: false).path
        guard FileManager.default.createFile(atPath: filePath, contents: fileContents.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: filePath)
        }
        
        print("✒︎ \(transportName) Dispatcher file saved.")
    }
    
    func buildDispatcherFile() throws -> String
    {
        // Try to find the template file in our bundle
        guard let fileURL = Bundle.module.url(forResource: Templates.NOMNIController.rawValue, withExtension: Extensions.txt.rawValue) else
        {
            throw TransportBuilderError.templateFileNotFound(filename: Templates.NOMNIController.rawValue)
        }
        
        // We found the file, update the contents.
        var fileContents = try String(contentsOf: fileURL)
        fileContents = fileContents.replacingOccurrences(of: Constants.placeholderTransportName, with: transportName)
        print("✒︎ \(transportName) Dispatcher file created.")
        return fileContents
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
        print("✒︎ \(transportName) toneburst file saved.")
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
        
        print("✒︎ \(transportName) toneburst file saved.")
        return savePath
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
}


