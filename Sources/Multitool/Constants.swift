//
//  Constants.swift
//
//
//  Created by Mafalda on 2/19/24.
//

import Foundation

struct Constants
{
    static let placeholderTransportName = "NOMNI"
    
    struct Directories {
        static let sources = "Sources"
        static let sourcesWithSlashes = "/" + sources + "/"
    }
    
    struct Files 
    {
        static let configFileName = "Config"
        static let configSwiftFileName = configFileName + Extensions.dotSwift.rawValue
        
        struct Readme
        {
            static let name = "README"
            static let transportsDescription = """
            ### Pluggable Transports
            """
            
        }
    }
    
    
}

enum Templates: String
{
    case NOMNIConfig
    case Package
    case PackageWithExtension = "Package.swift"
}

enum Extensions: String
{
    case swift
    case dotSwift = ".swift"
    case txt
    case dotTxt = ".txt"
}
