import Foundation

/// Generates hihat on the channel
class DrumsGenerator: Generator {
    
    let beatRow: Int
    
    var channelCount: Int {
        return 3
    }
    
    init(_ randomizer: inout RandomNumberGenerator) {
        // swiftlint:disable:next force_unwrapping
        let power = [1, 2].randomElement(using: &randomizer)!
        beatRow = Int(pow(2.0, Double(power)))
    }
    
    func applyNotes(
        channels: [ChannelID],
        pattern: Pattern,
        rhythm: Rhythm,
        beatBegin: Int,
        beatLength: Int,
        rootKey: Key,
        keyChord: Key,
        _ randomizer: inout RandomNumberGenerator
    ) {
        precondition(channelCount == channels.count)
        
        let beatEnd = beatBegin + beatLength
        
        for row in stride(from: beatBegin, to: beatEnd, by: beatRow) {
            // Hihat
            let command = Command(volume: 200)
            pattern.rows[row].setCommand(command, on: channels[0])
        }
        
        for row in stride(from: beatBegin, to: beatEnd, by: 2) {
            if (Float.random(in: 0...1, using: &randomizer) < 0.1) && (rhythm.rows[row] & 1 == 0) {
                // Kick
                let command = Command()
                pattern.rows[row].setCommand(command, on: channels[1])
            }
        }
        
        var didKick = false
        for row in beatBegin..<beatEnd {
            if rhythm.rows[row] & 1 > 0 {
                if didKick {
                    // Snare
                    let command = Command()
                    pattern.rows[row].setCommand(command, on: channels[2])
                } else {
                    if Float.random(in: 0...1, using: &randomizer) < 0.1 {
                        // Kick
                        let command = Command()
                        pattern.rows[row + 2].setCommand(command, on: channels[1])
                    } else {
                        // Kick
                        let command = Command()
                        pattern.rows[row].setCommand(command, on: channels[1])
                    }
                }
                
                didKick = !didKick
            }
        }
    }
}
