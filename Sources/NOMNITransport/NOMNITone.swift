//
//  NOMNITone.swift
//
//
//  Created by Mafalda on 3/5/24.
//

import Foundation

import Chord
import Datable
import Ghostwriter
import ReplicantSwift
import TransmissionAsync

public enum NOMNIToneMode: String, Codable {
    // NOMNIToneMode cases
    case NOMNImode
}

public class NOMNIToneAsync: ToneBurstAsync, Codable
{
    public var type: ReplicantSwift.ToneBurstType
    
    let mode: NOMNIToneMode

    public init(_ mode: NOMNIToneMode)
    {
        self.mode = mode
        self.type = .starburst
    }

    public func perform(connection: TransmissionAsync.AsyncConnection) async throws
    {
        let instance = NOMNIToneInstanceAsync(self.mode, connection)
        try await instance.perform()
    }
}

public struct NOMNIToneInstanceAsync
{
    let connection: TransmissionAsync.AsyncConnection
    let mode: NOMNIToneMode

    public init(_ mode: NOMNIToneMode, _ connection: TransmissionAsync.AsyncConnection)
    {
        self.mode = mode
        self.connection = connection
    }

    public func perform() async throws
    {
        switch mode
        {
            case .NOMNImode:
            try await handleNOMNImode()
        }
    }

    func handleNOMNImode() async throws
    {

    }

}

public enum NOMNIToneError: Error
{
    case timeout
    case connectionClosed
    case writeFailed
    case readFailed
    case listenFailed
    case speakFailed
    case maxSizeReached
}
