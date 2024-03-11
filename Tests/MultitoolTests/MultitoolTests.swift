import XCTest

import Ghostwriter
import OmniCompiler
import OmniLanguage
import Time

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
        guard let fileURL = Bundle.module.url(forResource: "NOMNIConfig", withExtension: Extensions.txt.rawValue) else
        {
            throw TransportBuilderError.templateFileNotFound(filename: "NOMNIConfig")
        }
        print("Toneburst template found at: \(fileURL.path)")
        
        guard let fileURL = Bundle.module.url(forResource: "Package", withExtension: Extensions.txt.rawValue) else
        {
            throw TransportBuilderError.templateFileNotFound(filename: "Package")
        }
        print("Toneburst template found at: \(fileURL.path)")
        
        guard let fileURL = Bundle.module.url(forResource: "Toneburst", withExtension: Extensions.txt.rawValue) else
        {
            throw TransportBuilderError.templateFileNotFound(filename: "Toneburst")
        }
        print("Toneburst template found at: \(fileURL.path)")
    }
    
    func testCreateModeFile() throws
    {
        let swiftBuilder = try SwiftTransportBuilder(projectDirectory: projectDirectory.path, transportName: newTransportName)
        let pop3ServerFunction = try createPOP3ServerFunction()
        let pop3ClientFunction = try createPOP3ClientFunction()
        let pop3ServerMode = ToneBurstMode(name: "POP3Server", function: pop3ServerFunction)
        let pop3ClientMode = ToneBurstMode(name: "POP3Client", function: pop3ClientFunction)
        let newToneburst = ToneBurstTemplate(name: "Omnitone", modes: [pop3ClientMode, pop3ServerMode])
        
        let newFilePath = try swiftBuilder.add(toneburst: newToneburst, saveDirectory: FileManager.default.homeDirectoryForCurrentUser)
        print("Saved a new transport file to: \(newFilePath)")
    }
    
    // An example of using OmniLanguage to create the code for a mode function
    func createPOP3ClientFunction() throws -> String
    {
        /*
         S> +OK POP3 server ready.
         C> STLS
         S> +OK Begin TLS Negotiation
         */

        let effect1 = GhostwriterListenEffect()
        let binding1 = Binding(value: .structuredText(StructuredText(
            .text("+OK POP3 server ready."), .newline(.crlf)
        )))
        let refinement1 = Refinement(name: "timeout", value: .timeDuration(TimeDuration(resolution: .seconds, ticks: 5)))
        let instance1 = EffectInstance(effect: effect1, binding: binding1, refinement: refinement1)

        let effect2 = GhostwriterSpeakEffect()
        let binding2 = Binding(value: .structuredText(StructuredText(
            .text("STLS"), .newline(.crlf)
        )))
        let instance2 = EffectInstance(effect: effect2, binding: binding2)

        let effect3 = GhostwriterListenEffect()
        let binding3 = Binding(value: .structuredText(StructuredText(
            .text("+OK Begin TLS Negotiation"), .newline(.crlf)
        )))
        let refinement3 = Refinement(name: "timeout", value: .timeDuration(TimeDuration(resolution: .seconds, ticks: 5)))
        let instance3 = EffectInstance(effect: effect3, binding: binding3, refinement: refinement3)

        let chain = EffectChain(
            instance: instance1,
            sequencer: Blocking(),
            chain: EffectChain(
                instance: instance2,
                sequencer: Sequential(),
                chain: EffectChain(
                    instance: instance3
                )
            )
        )

        print(chain.description)

        let compiler = SwiftOmniCompiler()
        let result = try compiler.compile("POP3Server", chain)

        return result.string
    }
    
    // An example of using OmniLanguage to create the code for a mode function
    func createPOP3ServerFunction() throws -> String
    {
        /*
         S> +OK POP3 server ready.
         C> STLS
         S> +OK Begin TLS Negotiation
         */

        let effect1 = GhostwriterSpeakEffect()
        let binding1 = Binding(value: .structuredText(StructuredText(
            .text("+OK POP3 server ready."), .newline(.crlf)
        )))
        let instance1 = EffectInstance(effect: effect1, binding: binding1)

        let effect2 = GhostwriterListenEffect()
        let binding2 = Binding(value: .structuredText(StructuredText(
            .text("STLS"), .newline(.crlf)
        )))
        let refinement = Refinement(name: "timeout", value: .timeDuration(TimeDuration(resolution: .seconds, ticks: 5)))
        let instance2 = EffectInstance(effect: effect2, binding: binding2, refinement: refinement)

        let effect3 = GhostwriterSpeakEffect()
        let binding3 = Binding(value: .structuredText(StructuredText(
            .text("+OK Begin TLS Negotiation"), .newline(.crlf)
        )))
        let instance3 = EffectInstance(effect: effect3, binding: binding3)

        let chain = EffectChain(
            instance: instance1,
            sequencer: Sequential(),
            chain: EffectChain(
                instance: instance2,
                sequencer: Blocking(),
                chain: EffectChain(
                    instance: instance3
                )
            )
        )

        print(chain.description)

        let compiler = SwiftOmniCompiler()
        let result = try compiler.compile("POP3Client", chain)

        return result.string
    }
}
