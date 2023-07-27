import Foundation

public protocol Generator: AnyObject {
    
    var channelCount: Int { get }
    
    func applyNotes(
        // Number of channel IDs should match channel count.
        channels: [ChannelID],
        pattern: Pattern,
        rhythm: Rhythm,
        beatBegin: Int,
        beatLength: Int,
        rootKey: Key,
        keyChord: Key,
        _ randomizer: inout SeededRandomNumberGenerator)
}
