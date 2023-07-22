//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

class MainStrategy: Strategy {
    
    let speed: Int
    var patternIndex: Int = 0
    let keySequence: [(Int, KeyType)]
    let keySequence2: [(Int, KeyType)]
    let rhythm: [Int]
    
    required init(baseNote: Int, keyType: KeyType, patternSize: Int, blockSize: Int, randomizer: inout SeededRandomNumberGenerator) {
       
        // swiftlint:disable:next force_unwrapping
        let power = [2, 3].randomElement(using: &randomizer)!
        speed = Int(pow(2.0, Double(power)))
        
        let rhythmCycle: [Int] = [3] + Array<Int>(repeating: 0, count: speed - 1) + [1] + Array<Int>(repeating: 0, count: speed - 1)
        var rhythm: [Int] = []
        let cycleCount = patternSize / rhythmCycle.count
        for _ in 0..<cycleCount {
            rhythm.append(contentsOf: rhythmCycle)
        }
        self.rhythm = rhythm
        
        //self.rhythm = [3] + [0] * (speed - 1) + [1] + [0] * (speed - 1)
        //self.rhythm *= (self.pattern_size // len(self.rhythm))
        
        let potentialKeys: [[(Int, KeyType)]]
        if keyType == .naturalMinor {
            potentialKeys = [
                [(0, .naturalMinor), (-4, .major), (5, .major), (-2, .major)],
                [(0, .naturalMinor), (-2, .major), (-4, .major), (-5, .naturalMinor)]
            ]
        } else {
            potentialKeys = [
                [(0, .major), (-5, .major), (-3, .naturalMinor), (5, .major)],
                [(0, .major), (0, .major), (-7, .naturalMinor), (-5, .major)]
            ]
        }
        // swiftlint:disable:next force_unwrapping
        keySequence = potentialKeys.randomElement(using: &randomizer)!
        
        let potentialKeys2: [[(Int, KeyType)]]
        if keyType == .naturalMinor {
            potentialKeys2 = [
                [(3, .major), (0, .naturalMinor), (-4, .major), (-2, .major)],
                [(-4, .major), (-2, .major), (0, .naturalMinor), (-2, .major)]
            ]
        } else {
            potentialKeys2 = [
                [(2, .naturalMinor), (0, .major), (-3, .naturalMinor), (0, .major)],
                [(-3, .naturalMinor), (-5, .major), (-7, .major), (-5, .major)]
            ]
        }
        // swiftlint:disable:next force_unwrapping
        keySequence2 = potentialKeys2.randomElement(using: &randomizer)!
        
        super.init(baseNote: baseNote, keyType: keyType, patternSize: patternSize, blockSize: blockSize, randomizer: &randomizer)
    }
    
    func generatePattern(randomizer: inout SeededRandomNumberGenerator) -> Pattern {
        let pattern = Pattern(rowCount: patternSize)
        
        var keySequence = (patternIndex % 8 >= 4) ? keySequence2 : self.keySequence
        
        for i in stride(from: 0, to: patternSize, by: blockSize) {
            let (key, keyType) = keySequence.removeFirst()
            let keyChord = Key(baseNote: self.key.baseNote + key, keyType: keyType)
            for (channel, generator) in generators {
                generator.applyNotes(
                    channel: channel,
                    pattern: pattern,
                    rhythm: rhythm,
                    beatBegin: i,
                    beatLength: blockSize,
                    rootKey: self.key,
                    keyChord: keyChord,
                    randomizer: &randomizer)
            }
            
            keySequence.append((key, keyType))
        }
        
        patterns.append(pattern)
        
        patternIndex += 1
        
        return pattern
    }
    
}
