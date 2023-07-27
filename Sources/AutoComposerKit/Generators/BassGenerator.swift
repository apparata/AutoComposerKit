import Foundation

class BassGenerator: Generator {
    
    var channelCount: Int {
        return 1
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
        let channel = channels[0]
        
        let beatEnd = beatBegin + beatLength
        
        let base = keyChord.baseNote
        
        var leadIn = 0
        
        for row in beatBegin..<beatEnd {
            if rhythm.rows[row] & 1 > 0 {
                let note = (Float.random(in: 0...1, using: &randomizer) < 0.5) ? base - 12 : base
                pattern.rows[row].setCommand(
                    Command(command: .playNote(note)),
                    on: channel)
                
                if leadIn != 0 && Float.random(in: 0...1, using: &randomizer) < 0.4 {
                    let gran = 2
                    var count = 1
                    
                    if leadIn > gran * 2 && Float.random(in: 0...1, using: &randomizer) < 0.4 {
                        count += 1
                        if leadIn > gran * 3 && Float.random(in: 0...1, using: &randomizer) < 0.4 {
                            count += 1
                        }
                    }
                    
                    for j in 0..<count {
                        pattern.rows[row - (j + 1) * gran].setCommand(
                            Command(command: .playNote((Float.random(in: 0...1, using: &randomizer) < 0.5) ? base + 12 : base)),
                            on: channel)
                    }
                }
                
                if Float.random(in: 0...1, using: &randomizer) < 0.2 {
                    // swiftlint:disable:next force_unwrapping
                    let channelCommand = pattern.rows[row].channels[channel]!
                    channelCommand.command = NoteCommand(note: channelCommand.command.value + 12)
                    if Float.random(in: 0...1, using: &randomizer) >= 0.4 {
                        pattern.rows[row + 2].setCommand(
                            Command(command: .noteCut),
                            on: channel)
                    }
                }
                
                leadIn = 0
            } else {
                leadIn += 1
            }
        }
    }
    
}
