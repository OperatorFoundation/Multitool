import XCTest
@testable import Multitool

final class MultitoolTests: XCTestCase 
{
    let projectDirectory = FileManager.default.homeDirectoryForCurrentUser.appending(path: "CodeTesting", directoryHint: .isDirectory)
    let newTransportName = "Mycellium"
    
    
    func testBuildConfig() throws
    {
        let swiftBuilder = try SwiftTransportBuilder(projectDirectory: projectDirectory.path, transportName: newTransportName)
        let configContents = try swiftBuilder.buildConfigFile()
        print("Created a config file from a template: \n\(configContents)")
    }
    
    func testGetToneburstTemplate() throws
    {
        let swiftBuilder = try SwiftTransportBuilder(projectDirectory: projectDirectory.path, transportName: newTransportName)
        try swiftBuilder.addToneburstFile()
    }
    
    func testAddModes() throws
    {
        let swiftBuilder = try SwiftTransportBuilder(projectDirectory: projectDirectory.path, transportName: newTransportName)
        try swiftBuilder.addModes(called: ["POP3Server, POP3Client"])
    }
}
