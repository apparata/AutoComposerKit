//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

class BassGenerator: Generator {
    
    var size: Int {
        return 1
    }
    
    func applyNotes(channel: Int, pattern: Pattern, rhythm: [Int], beatBegin: Int, beatLength: Int, rootKey: Key, keyChord: Key, randomizer: inout SeededRandomNumberGenerator) {
        let beatEnd = beatBegin + beatLength
        
        let base = keyChord.baseNote
        
        var leadIn = 0
        
        for row in beatBegin..<beatEnd {
            if rhythm[row] & 1 > 0 {
                let note = (Float.random(in: 0...1, using: &randomizer) < 0.5) ? base - 12 : base
                pattern.data[row][channel] = [note, Instrument.bass.rawValue, 255, 0, 0]
                
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
                        pattern.data[row - (j + 1) * gran][channel] = [
                            (Float.random(in: 0...1, using: &randomizer) < 0.5) ? base + 12 : base,
                            Instrument.bass.rawValue,
                            0xFF,
                            19, // ord('S') - ord('A') + 1
                            // swiftlint:disable:next force_unwrapping
                            0xC0 + [1, 2].randomElement(using: &randomizer)!
                        ]
                    }
                }
                
                if Float.random(in: 0...1, using: &randomizer) < 0.2 {
                    pattern.data[row][channel][0] += 12
                    if Float.random(in: 0...1, using: &randomizer) < 0.4 {
                        pattern.data[row][channel][3] = 19 // ord('S') - ord('A') + 1
                        // swiftlint:disable:next force_unwrapping
                        pattern.data[row][channel][4] = 0xC0 + [1, 2].randomElement(using: &randomizer)!
                    } else {
                        pattern.data[row + 2][channel] = [254, Instrument.bass.rawValue, 0xFF, 0, 0]
                    }
                }
                
                leadIn = 0
            } else {
                leadIn += 1
            }
        }
    }
    
}
