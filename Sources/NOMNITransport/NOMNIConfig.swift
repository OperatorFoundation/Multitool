//
//  NOMNIConfig.swift
//
//

import Foundation

import KeychainTypes

public class NOMNIConfig
{
    public struct NOMNIServerConfig: Codable
    {
        public static let serverConfigFilename = "NOMNIServerConfig.json"
        public let serverAddress: String
        public let serverIP: String
        public let serverPort: UInt16
        public let serverPrivateKey: PrivateKey
        public var transportName = "NOMNI"
        
        private enum CodingKeys : String, CodingKey
        {
            case serverAddress
            case serverPrivateKey
            case transportName = "transport"
        }
        
        public init(serverAddress: String, serverPrivateKey: PrivateKey) throws
        {
            self.serverAddress = serverAddress
            
            let addressStrings = serverAddress.replacingOccurrences(of: " ", with: "").split(separator: ":")
            self.serverIP = String(addressStrings[0])
            guard let port = UInt16(addressStrings[1]) else
            {
                print("Error decoding NOMNIServerConfig data: invalid server port \(addressStrings[1])")
                throw NOMNIError.missingPortInformation(address: serverAddress)
            }
            
            self.serverPort = port
            self.serverPrivateKey = serverPrivateKey
        }
        
        public init?(from data: Data)
        {
            let decoder = JSONDecoder()
            do
            {
                let decoded = try decoder.decode(NOMNIServerConfig.self, from: data)
                
                self = decoded
            }
            catch
            {
                print("Error received while attempting to decode a NOMNIConfig json file: \(error)")
                return nil
            }
        }
        
        public init?(path: String)
        {
            let url = URL(fileURLWithPath: path)
            
            do
            {
                let data = try Data(contentsOf: url)
                self.init(from: data)
            }
            catch
            {
                print("Error decoding NOMNI config file: \(error)")
                
                return nil
            }
        }
        
        public init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let address = try container.decode(String.self, forKey: .serverAddress)
            let addressStrings = address.replacingOccurrences(of: " ", with: "").split(separator: ":")
            let ipAddress = String(addressStrings[0])
            guard let port = UInt16(addressStrings[1]) else
            {
                print("Error decoding NOMNIConfig data: invalid server port")
                throw NOMNIError.missingPortInformation(address: address)
            }
            
            self.serverAddress = address
            self.serverIP = ipAddress
            self.serverPort = port
            self.serverPrivateKey = try container.decode(PrivateKey.self, forKey: .serverPrivateKey)
            self.transportName = try container.decode(String.self, forKey: .transportName)
        }
    }
    
    public struct NOMNIClientConfig: Codable, Equatable
    {
        public static let clientConfigFilename = "NOMNIClientConfig.json"
        public let serverAddress: String
        public let serverIP: String
        public let serverPort: UInt16
        public let serverPublicKey: PublicKey
        public var transportName = "NOMNI"
        
        private enum CodingKeys : String, CodingKey
        {
            case serverAddress, serverPublicKey, transportName = "transport"
        }
        
        public init(serverAddress: String, serverPublicKey: PublicKey) throws
        {
            self.serverAddress = serverAddress
            
            let addressStrings = serverAddress.replacingOccurrences(of: " ", with: "").split(separator: ":")
            let ipAddress = String(addressStrings[0])
            guard let port = UInt16(addressStrings[1]) else
            {
                print("Error decoding NOMNIConfig data: invalid server port")
                throw NOMNIError.missingPortInformation(address: serverAddress)
            }
            
            self.serverIP = ipAddress
            self.serverPort = port
            self.serverPublicKey = serverPublicKey
        }
        
        public init?(from data: Data)
        {
            let decoder = JSONDecoder()
            do
            {
                let decoded = try decoder.decode(NOMNIClientConfig.self, from: data)
                self = decoded
            }
            catch
            {
                print("Error received while attempting to decode a NOMNIConfig json file: \(error)")
                return nil
            }
        }
        
        public init?(path: String)
        {
            let url = URL(fileURLWithPath: path)
            
            do
            {
                let data = try Data(contentsOf: url)
                self.init(from: data)
            }
            catch
            {
                print("Error decoding NOMNI config file: \(error)")
                
                return nil
            }
        }
        
        public init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let address = try container.decode(String.self, forKey: .serverAddress)
            let addressStrings = address.replacingOccurrences(of: " ", with: "").split(separator: ":")
            let ipAddress = String(addressStrings[0])
            guard let port = UInt16(addressStrings[1]) else
            {
                print("Error decoding NOMNIConfig data: invalid server port")
                throw NOMNIError.missingPortInformation(address: address)
            }
            
            self.serverAddress = address
            self.serverIP = ipAddress
            self.serverPort = port
            self.serverPublicKey = try container.decode(PublicKey.self, forKey: .serverPublicKey)
            self.transportName = try container.decode(String.self, forKey: .transportName)
        }
    }

    public static func generateNewConfigPair(serverAddress: String) throws -> (serverConfig: NOMNIServerConfig, clientConfig: NOMNIClientConfig)
    {
        let privateKey = try PrivateKey(type: .P256KeyAgreement)
        let publicKey = privateKey.publicKey

        let serverConfig = try NOMNIServerConfig(serverAddress: serverAddress, serverPrivateKey: privateKey)
        let clientConfig = try NOMNIClientConfig(serverAddress: serverAddress, serverPublicKey: publicKey)
        
        return (serverConfig, clientConfig)
    }

    public static func createNewConfigFiles(inDirectory saveDirectory: URL, serverAddress: String) throws
    {
        guard saveDirectory.hasDirectoryPath else
        {
            throw NOMNIError.urlIsNotDirectory(urlPath: saveDirectory.path)
        }

        let configPair = try NOMNIConfig.generateNewConfigPair(serverAddress: serverAddress)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        
        let serverJson = try encoder.encode(configPair.serverConfig)
        let serverConfigFilePath = saveDirectory.appendingPathComponent(NOMNIServerConfig.serverConfigFilename).path
        
        guard FileManager.default.createFile(atPath: serverConfigFilePath, contents: serverJson) else
        {
            throw NOMNIError.failedToSaveFile(filePath: serverConfigFilePath)
        }

        let clientJson = try encoder.encode(configPair.clientConfig)
        let clientConfigFilePath = saveDirectory.appendingPathComponent(NOMNIClientConfig.clientConfigFilename).path

        guard FileManager.default.createFile(atPath: clientConfigFilePath, contents: clientJson) else
        {
            throw NOMNIError.failedToSaveFile(filePath: clientConfigFilePath)
        }
    }

}

