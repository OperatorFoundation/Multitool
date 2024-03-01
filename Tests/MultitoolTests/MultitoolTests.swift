import XCTest
@testable import Multitool

final class MultitoolTests: XCTestCase 
{
    func testBuildConfig() throws
    {
        let swiftBuilder = try SwiftTransportBuilder(projectDirectory: "projectDirectory", transportName: "Mycellium")
        
        let configContents = try swiftBuilder.buildConfigFile()
        print("Created a config file from a template: \n\(configContents)")
    }
}
