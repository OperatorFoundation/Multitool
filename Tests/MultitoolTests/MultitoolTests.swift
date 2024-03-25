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
    let modes = ["SMTPClient, SMTPServer"]
    let newToneburstName = "Starburst"
    
    
    func testBuildConfig() throws
    {
        let swiftBuilder = try SwiftTransportBuilder(saveDirectory: projectDirectory.path, transportName: newTransportName, modes: modes, toneburstName: newToneburstName)
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
    
    func testCreateOmnitoneFile() throws
    {
        let swiftBuilder = try SwiftTransportBuilder(saveDirectory: projectDirectory.path, transportName: newTransportName, modes: modes, toneburstName: newToneburstName)
        let pop3ServerFunction = try createPOP3ServerFunction()
        print("pop3ServerFunction: \n \(pop3ServerFunction)")
        
        let pop3ClientFunction = try createPOP3ClientFunction()
        print("pop3ClientFunction: \n \(pop3ClientFunction)")
        
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
        let listen1 = EffectInstance(effect: effect1, binding: binding1)

        let effect2 = GhostwriterSpeakEffect()
        let binding2 = Binding(value: .structuredText(StructuredText(
            .text("STLS"), .newline(.crlf)
        )))
        let speak1 = EffectInstance(effect: effect2, binding: binding2)

        let effect3 = GhostwriterListenEffect()
        let binding3 = Binding(value: .structuredText(StructuredText(
            .text("+OK Begin TLS Negotiation"), .newline(.crlf)
        )))
        let listen2 = EffectInstance(effect: effect3, binding: binding3)
        
        let effect4 = EndProgramEffect()
        let end = EffectInstance(effect: effect4)
        
        let timeoutDuration = TimeDuration(resolution: .seconds, ticks: 5)

        let chain = EffectChain(
            instance: listen1,
            sequencer: Waiting(timeoutDuration),
            chain: EffectChain(
                instance: speak1,
                sequencer: Sequential(),
                chain: EffectChain(
                    instance: listen2,
                    sequencer: Waiting(timeoutDuration),
                    chain: EffectChain(instance: end)
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
        let speak1 = EffectInstance(effect: effect1, binding: binding1)

        let effect2 = GhostwriterListenEffect()
        let binding2 = Binding(value: .structuredText(StructuredText(
            .text("STLS"), .newline(.crlf)
        )))
        let listen1 = EffectInstance(effect: effect2, binding: binding2)

        let effect3 = GhostwriterSpeakEffect()
        let binding3 = Binding(value: .structuredText(StructuredText(
            .text("+OK Begin TLS Negotiation"), .newline(.crlf)
        )))
        let speak2 = EffectInstance(effect: effect3, binding: binding3)
        
        let timeoutDuration = TimeDuration(resolution: .seconds, ticks: 5)
        
        let chain = EffectChain(
            instance: speak1,
            sequencer: Sequential(),
            chain: EffectChain(
                instance: listen1,
                sequencer: Waiting(timeoutDuration),
                chain: EffectChain(
                    instance: speak2
                )
            )
        )

        print(chain.description)

        let compiler = SwiftOmniCompiler()
        let result = try compiler.compile("POP3Client", chain)

        return result.string
    }
    
    func testBuildConfigFile() throws
    {
        let newConfigFilePath = ""
        
        let swiftTransportBuilder = try SwiftTransportBuilder(saveDirectory: projectDirectory.path, transportName: newTransportName, modes: modes, toneburstName: newToneburstName)
        try swiftTransportBuilder.addConfigFile(filePath: newConfigFilePath)
        
        print("Added a config file to: \(projectDirectory.path)")
    }
    
    func testCreateStarburstFile() throws
    {
        let swiftBuilder = try SwiftTransportBuilder(saveDirectory: projectDirectory.path, transportName: newTransportName, modes: ["SMTPServer, SMTPClient"], toneburstName: "Starburst")
        let smtpServerFunction = try createSMTPServerFunction()
        let smtpClientFunction = try createSMTPClientFunction()
        let smtpServerMode = ToneBurstMode(name: "SMTPServer", function: smtpServerFunction)
        let smtpClientMode = ToneBurstMode(name: "SMTPClient", function: smtpClientFunction)
        let newToneburst = ToneBurstTemplate(name: "Starburst", modes: [smtpClientMode, smtpServerMode])
        
        let newFilePath = try swiftBuilder.add(toneburst: newToneburst, saveDirectory: FileManager.default.homeDirectoryForCurrentUser)
        print("Saved a new Starburst file to: \(newFilePath)")
    }
    
    func createSMTPClientFunction() throws -> String
    {
        // Listen
        let listenEffect1 = GhostwriterListenEffect()
        let listenBinding1 = Binding(value: .structuredText(StructuredText(TypedText.text("220 "), TypedText.regexp("^([a-zA-Z0-9.-]+)"), TypedText.text(" SMTP service ready"), TypedText.newline(.crlf))
        ))
        let listen1 = EffectInstance(effect: listenEffect1, binding: listenBinding1)

        // Speak
        let speakEffect1 = GhostwriterSpeakEffect()
        let speakBinding1 = Binding(value: .structuredText(StructuredText(TypedText.text("EHLO mail.imc.org"), TypedText.newline(.crlf))
        ))
        let speak1 = EffectInstance(effect: speakEffect1, binding: speakBinding1)

        // Listen
        let listenEffect2 = GhostwriterListenEffect()
        let listenBinding2 = Binding(value: .structuredText(StructuredText(TypedText.text("250 STARTTLS"), TypedText.newline(.crlf))
        ))
        let listen2 = EffectInstance(effect: listenEffect2, binding: listenBinding2)
        
        // Speak
        let speakEffect2 = GhostwriterSpeakEffect()
        let speakBinding2 = Binding(value: .structuredText(StructuredText(TypedText.text("STARTTLS"), TypedText.newline(.crlf))
        ))
        let speak2 = EffectInstance(effect: speakEffect2, binding: speakBinding2)
            
        // Listen
        let listenEffect3 = GhostwriterListenEffect()
        let listenBinding3 = Binding(value: .structuredText(StructuredText(TypedText.regexp("^(.+)$"), TypedText.newline(.crlf))
        ))
        let listen3 = EffectInstance(effect: listenEffect3, binding: listenBinding3)

        // End
        let endEffect = EndProgramEffect()
        let end = EffectInstance(effect: endEffect)

        let timeout = TimeDuration(resolution: .seconds, ticks: 10)

        let chain = EffectChain(
            instance: listen1,
            sequencer: Waiting(timeout),
            chain: EffectChain(
                instance: speak1,
                sequencer: Sequential(),
                chain: EffectChain(
                    instance: listen2,
                    sequencer: Waiting(timeout),
                    chain: EffectChain(
                        instance: speak2,
                        sequencer: Sequential(),
                        chain: EffectChain(
                            instance: listen3,
                            sequencer: Waiting(timeout),
                            chain: EffectChain(
                                instance: end
                            )
                        )
                    )
                )
            )
        )

        let compiler = SwiftOmniCompiler()
        let result = try compiler.compile("SMTPClient", chain)

        print(result.string)
        return result.string
    }
    
    func createSMTPServerFunction() throws -> String
    {
//        try await speak(template: Template("220 $1 SMTP service ready\r\n"), details: [Detail.string("mail.imc.org")])
        
        // FIXME: Speak
        let speakEffect1 = GhostwriterSpeakEffect()
        let speakBinding1 = Binding(value: .structuredText(StructuredText(TypedText.text("220 mail.imc.org SMTP service ready"), TypedText.newline(.crlf))))
        let speak1 = EffectInstance(effect: speakEffect1, binding: speakBinding1)
        //
        
        
        
        // TODO: Listen
        //        guard let firstServerListen = ListenTemplate(Template("EHLO $1\r\n"), patterns: [ExtractionPattern("^([a-zA-Z0-9.-]+)\r", .string)], maxSize: 253, maxTimeoutSeconds: 10) else {
        //            throw StarburstError.listenFailed
        //        }
        //
        //        _ = try await listen(template: firstServerListen)
        let listenEffect1 = GhostwriterListenEffect()
        let listenBinding1 = Binding(value: .structuredText(StructuredText(TypedText.text("EHLO "), TypedText.regexp("^([a-zA-Z0-9.-]+)$"), TypedText.newline(.crlf))))
        let listen1 = EffectInstance(effect: listenEffect1, binding: listenBinding1)
        
        // TODO: Speak
        // % 5 is mod, which divides by five, discards the result, then returns the remainder
        let hour = Calendar.current.component(.hour, from: Date()) % 5
        let welcome: String
        switch hour
        {
            // These are all real SMTP welcome messages found in online examples of SMTP conversations.
            case 0:
                welcome = "offers a warm hug of welcome"
            case 1:
                welcome = "is my domain name."
            case 2:
                welcome = "I am glad to meet you"
            case 3:
                welcome = "says hello"
            case 4:
                welcome = "Hello"

            default:
                welcome = ""
        }
        //        try await speak(template: Template("250-$1 $2\r\n250-$3\r\n250-$4\r\n250 $5\r\n"), details: [Detail.string("mail.imc.org"), Detail.string(welcome), Detail.string("8BITMIME"), Detail.string("DSN"), Detail.string("STARTTLS")])
        let speakEffect2 = GhostwriterSpeakEffect()
        let speakBinding2 = Binding(value: .structuredText(StructuredText(TypedText.text("250 mail.imc.org "), TypedText.text(welcome.text), TypedText.newline(.crlf), TypedText.text("250-8BITMIME"), TypedText.newline(.crlf), TypedText.text("250-DSN"), TypedText.newline(.crlf), TypedText.text("250 STARTTLS"), TypedText.newline(.crlf))))
        let speak2 = EffectInstance(effect: speakEffect2, binding: speakBinding2)
        
        // TODO: Listen
        //        // FIXME: not sure about this size
        //        let _: String = try await listen(size: "STARTTLS\r\n".count + 1) // \r\n is counted as one on .count
        let listenEffect2 = GhostwriterListenEffect()
        let listenBinding2 = Binding(value: .structuredText(StructuredText(TypedText.text("STARTTLS"), TypedText.newline(.crlf))))
        let listen2 = EffectInstance(effect: listenEffect2, binding: listenBinding2)
        
        // TODO: Speak 
        //        try await speak(template: Template("220 $1\r\n"), details: [Detail.string("Go ahead")])
        let speakEffect3 = GhostwriterSpeakEffect()
        let speakBinding3 = Binding(value: .structuredText(StructuredText(TypedText.text("220 Go ahead"), TypedText.newline(.crlf))))
        let speak3 = EffectInstance(effect: speakEffect3, binding: speakBinding3)
        
        let endEffect = EndProgramEffect()
        let end = EffectInstance(effect: endEffect)
        
        let timeoutDuration = TimeDuration(resolution: .seconds, ticks: 10)
        
//        let chain = EffectChain(instance: speak1, sequencer: Sequential(), chain: EffectChain(instance: end))
        let chain = EffectChain(
            instance: speak1,
            sequencer: Sequential(),
            chain:  EffectChain(
                instance: listen1,
                sequencer: Waiting(timeoutDuration),
                chain: EffectChain(
                    instance: speak2,
                    sequencer: Sequential(),
                    chain: EffectChain(
                        instance: listen2,
                        sequencer: Waiting(timeoutDuration),
                        chain: EffectChain(
                            instance: speak3,
                            sequencer: Sequential(),
                                chain: EffectChain(
                                    instance: end
                                )
                            )
                        )
                    )
                )
            )
        
        let compiler = SwiftOmniCompiler()
        let result = try compiler.compile("SMTPServer", chain)
        
        print(result.string)
        return result.string
    }

}
