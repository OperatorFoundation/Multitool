//
//  Constants.swift
//
//
//  Created by Mafalda on 2/19/24.
//

import Foundation

struct Constants
{
    struct Directories {
        
        static let sources = "Sources"
        static let sourcesWithSlashes = "/" + sources + "/"
        
    }
    
    struct Files 
    {
        static let swiftExtension = ".swift"
        static let clientConfigFile = "ClientConfig"
        static let clientConfigSwiftFile = clientConfigFile + swiftExtension
        static let serverConfigFile = "ServerConfig"
        static let serverConfigSwiftFile = serverConfigFile + swiftExtension
        
        struct Readme
        {
            static let name = "README"
            static let transportsDescription = """
            ### Pluggable Transports
            """
            
        }
    }
}
