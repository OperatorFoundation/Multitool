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
    let toneburstDirectory: URL
    let toneburstName: String
    
    init(saveDirectory: String, transportName: String, toneburstDirectory: URL) throws
    {
        guard let newSwift: SwiftTool = SwiftTool() else
        {
            throw TransportBuilderError.swiftEnvironmentCreationFailure
        }
        
        self.swift = newSwift
        self.toneburstDirectory = toneburstDirectory
        self.transportName = transportName
        self.saveDirectory = URL(fileURLWithPath: saveDirectory)
        self.projectDirectory = URL(fileURLWithPath: saveDirectory).appendingPathComponent(transportName, isDirectory: true)
        self.sourcesDirectory = self.projectDirectory.appendingPathComponent("\(Constants.Directories.sources)/\(transportName)/", isDirectory: true)
        self.toneburstName = toneburstDirectory.lastPathComponent
        
        guard let fileNames = File.contentsOfDirectory(atPath: toneburstDirectory.path) else
        {
            throw SwiftToneBurstBuilderError.noToneburstFound
        }

        let modes = fileNames.map
        {
            modeName in
            
            let name = URL(fileURLWithPath: modeName).deletingPathExtension().lastPathComponent
            
            return name
        }
        self.modes = modes
    }
    
    func buildNewTransport() throws
    {
        try buildProjectStructure(projectDirectory: projectDirectory)
        try addStandardFiles()
        try add()
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
    
    func add() throws
    {
        let builder = try SwiftToneburstBuilder(toneburstDirectory: self.toneburstDirectory)
        try builder.buildNewToneburst()
                
        print("🅾 Building Toneburst Generator...")
        guard let _ = self.swift.build() else
        {
            throw SwiftTransportBuilderError.buildFailed
        }
        print("🅾 Built Toneburst Generator.")
        
        print("🅾 Running Toneburst Generator...")
        guard let _ = self.swift.run() else
        {
            throw SwiftTransportBuilderError.runFailed
        }
        print("🅾 Ran Toneburst Generator.")
        
        guard let generatedToneburstModesFilenames = File.contentsOfDirectory(atPath: builder.outputDirectory.path) else
        {
            throw SwiftTransportBuilderError.toneburstDirectoryDoesNotExist
        }
        
        let modes: [ToneBurstMode] = try generatedToneburstModesFilenames.map
        {
            modeName in
            
            let name = URL(fileURLWithPath: modeName).deletingPathExtension().lastPathComponent
            let modeURL = builder.outputDirectory.appendingPathComponent(modeName)
            let code = try Data(contentsOf: modeURL).string
            let mode = ToneBurstMode(name: name, function: code)
            
            return mode
        }
        
        builder.deleteTempDirectory()
        print("🅾 Tempory Toneburst Generation directory deleted at: \(builder.projectDirectory)")
        
        let toneburstTemplate = ToneBurstTemplate(name: self.toneburstName, modes: modes)
        
        let rendered = try ToneBurstTemplate.create(toneburst: toneburstTemplate)

        let savePath = sourcesDirectory.appendingPathComponent(self.toneburstName + Extensions.dotSwift.rawValue, isDirectory: false).path
        
        guard FileManager.default.createFile(atPath: savePath, contents: rendered.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: savePath)
        }
        
        print("🅾 \(transportName) toneburst file saved.")
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

public enum SwiftTransportBuilderError: Error
{
    case buildFailed
    case runFailed
    case toneburstDirectoryDoesNotExist
}


