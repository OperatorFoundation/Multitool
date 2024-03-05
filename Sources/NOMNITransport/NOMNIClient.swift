//
//  NOMNIClient.swift
//
//
//  Created by Mafalda on 3/4/24.
//

import Foundation
import Logging

import TransmissionAsync

public class NOMNIClient
{
    let connection: AsyncConnection
    let logger: Logger
    
    public init(connection: AsyncConnection, logger: Logger)
    {
        self.connection = connection
        self.logger = logger
    }
}
