//
//  NOMNIServer.swift
//
//
//  Created by Mafalda on 3/4/24.
//

import Foundation
import Logging

import Antiphony
import TransmissionAsync

public class NOMNIServer
{
    let listener: AsyncListener
    let logger: Logger
    
    var running: Bool = true
    
    public init(listener: AsyncListener, logger: Logger) async
    {
        self.listener = listener
        self.logger = logger
        
        await self.acceptLoop()
    }
    
    public convenience init(serverConfigURL: URL, logger: Logger) async throws
    {
        
        let antiphonyServer = try Antiphony(serverConfigURL: serverConfigURL, logger: logger)
        guard let antiphonyListener = antiphonyServer.listener else
        {
            throw NOMNIError.failedToLaunchServer
        }
        
        await self.init(listener: antiphonyListener, logger: antiphonyServer.logger)
    }
    
    func handleConnection(connection: AsyncConnection) async throws
    {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        
        while self.running
        {
            do
            {
                let nomniPacket = try await connection.readWithLengthPrefix(prefixSizeInBits: NOMNI.prefixSizeInBits)
            }
            catch
            {
                logger.info("NOMNI server received an error while trying to read from a client connection: \(error)")
                return
            }
        }
    }
    
    func acceptLoop() async
    {
        while self.running
        {
            do
            {
                let connection = try await self.listener.accept()
                
                Task
                {
                    try await self.handleConnection(connection: connection)
                }
            }
            catch
            {
                logger.info("Received an error while trying to handle a connection: \(error)")
                shutdown()
                return
            }
        }
    }
    
    public func shutdown()
    {
        self.running = false
    }
}
