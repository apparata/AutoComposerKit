//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

class DrumsGenerator: Generator {
    
    let beatRow: Int
    
    var size: Int {
        return 3
    }
    
    init(randomizer: inout SeededRandomNumberGenerator) {
        // swiftlint:disable:next force_unwrapping
        let power = [1, 2].randomElement(using: &randomizer)!
        beatRow = Int(pow(2.0, Double(power)))
    }
    
    func applyNotes(channel: Int, pattern: Pattern, rhythm: [Int], beatBegin: Int, beatLength: Int, rootKey: Key, keyChord: Key, randomizer: inout SeededRandomNumberGenerator) {
        let beatEnd = beatBegin + beatLength
        
        for row in stride(from: beatBegin, to: beatEnd, by: beatRow) {
            var volume = 255
            var instrument = Instrument.hihatClosed
            if (rhythm[row] & 2) == 0 {
                if (row & 8) > 0 {
                    volume = 48
                }
                if (row & 4) > 0 {
                    volume = 32
                }
                if (row & 2) > 0 {
                    volume = 16
                }
                if (row & 1) > 0 {
                    volume = 8
                }
                
                if Float.random(in: 0...1, using: &randomizer) < 0.2 {
                    instrument = Instrument.hihatOpen
                }
            }
            
            pattern.data[row][channel] = [60, instrument.rawValue, volume, 0, 0]
        }
        
        for row in stride(from: beatBegin, to: beatEnd, by: 2) {
            if (Float.random(in: 0...1, using: &randomizer) < 0.1) && (rhythm[row] & 1 == 0) {
                pattern.data[row][channel + 1] = [60, Instrument.kickDrum.rawValue, 255, 0, 0]
            }
        }
        
        var didKick = false
        for row in beatBegin..<beatEnd {
            if rhythm[row] & 1 > 0 {
                if didKick {
                    pattern.data[row][channel + 2] = [60, Instrument.snareDrum.rawValue, 255, 0, 0]
                } else {
                    if Float.random(in: 0...1, using: &randomizer) < 0.1 {
                        pattern.data[row + 2][channel + 1] = [60, Instrument.kickDrum.rawValue, 255, 0, 0]
                    } else {
                        pattern.data[row][channel + 1] = [60, Instrument.kickDrum.rawValue, 255, 0, 0]
                    }
                }
                
                didKick = !didKick
            }
        }
    }
}
