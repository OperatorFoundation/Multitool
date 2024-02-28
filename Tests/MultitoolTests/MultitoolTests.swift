import XCTest
@testable import Multitool

final class MultitoolTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testBuildConfig() throws
    {
        let swiftBuilder = try SwiftTransportBuilder(projectDirectory: "projectDirectory", transportName: "name")
        
        try swiftBuilder.buildTransportConfigFile()
    }
}
