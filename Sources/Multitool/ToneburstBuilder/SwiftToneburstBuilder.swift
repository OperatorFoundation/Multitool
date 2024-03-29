//
// SwiftToneburstBuilder.swift
//
//
//  Created by Joseph Bragel on 3/28/24.
//

import Foundation

import Gardener
import Stencil

struct SwiftToneburstBuilder
{
    public let projectDirectory: URL
    
    let saveDirectory: URL
    let sourcesDirectory: URL
    let swift: SwiftTool
    let toneburstDirectory: URL
    let toneburstName: String
    
    init(toneburstDirectory: URL) throws
    {
        self.toneburstDirectory = toneburstDirectory
        self.toneburstName = toneburstDirectory.lastPathComponent
        self.saveDirectory = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: File.homeDirectory(), create: true)
        
        guard let newSwift: SwiftTool = SwiftTool() else
        {
            throw TransportBuilderError.swiftEnvironmentCreationFailure
        }
        
        self.swift = newSwift
        self.projectDirectory = saveDirectory.appendingPathComponent(toneburstName, isDirectory: true)
        self.sourcesDirectory = self.projectDirectory.appendingPathComponent("\(Constants.Directories.sources)/\(toneburstName)/", isDirectory: true)
    }
    
    func buildNewToneburst() throws
    {
        try buildProjectStructure(projectDirectory: self.projectDirectory)
        try addStandardFiles()
        try addMain()
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
    }
    
    func addPackageFile() throws
    {
        let rendered = try TemplateBuilder.create(context: ["name": self.toneburstName], templateName: "Package-main")
        
        let savePath = sourcesDirectory.appendingPathComponent("Package" + Extensions.dotSwift.rawValue, isDirectory: false).path
        
        guard FileManager.default.createFile(atPath: savePath, contents: rendered.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: savePath)
        }
        
        print("✒︎ Package file saved.")
    }
    
    func addMain() throws
    {
        guard let fileNames = File.contentsOfDirectory(atPath: self.toneburstDirectory.path) else
        {
            throw SwiftToneBurstBuilderError.noToneburstFound
        }

        let modes = try fileNames.map
        {
            modeName in
            
            let name = URL(fileURLWithPath: modeName).deletingPathExtension().path
            let modeURL = self.toneburstDirectory.appendingPathComponent(modeName)
            let omniCode = try Data(contentsOf: modeURL).string
            let mode = ToneburstBuilderMode(name: name, omnicode: omniCode)
            
            return mode
        }
        
        let rendered = try TemplateBuilder.create(context: ["name": self.toneburstName, "modes": modes], templateName: "main")
        let savePath = sourcesDirectory.appendingPathComponent("main" + Extensions.dotSwift.rawValue, isDirectory: false).path
        
        guard FileManager.default.createFile(atPath: savePath, contents: rendered.data) else
        {
            throw TransportBuilderError.failedToSaveFile(filePath: savePath)
        }
        
        print("✒︎ main file saved.")
    }
}

public enum SwiftToneBurstBuilderError: Error
{
    case noToneburstFound
}
