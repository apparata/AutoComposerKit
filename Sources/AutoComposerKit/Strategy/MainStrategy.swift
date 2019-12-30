//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

class MainStrategy: Strategy {
    
    var speed: Int = Int(pow(2.0, Double([2, 3].randomElement()!)))
    var patternIndex: Int = 0
    let keySequence: [(Int, KeyType)]
    let keySequence2: [(Int, KeyType)]
    let rhythm: [Int]
    
    required init(baseNote: Int, keyType: KeyType, patternSize: Int, blockSize: Int) {
        
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
        if keyType == .minor {
            potentialKeys = [
                [(0, .minor), (-4, .major), (5, .major), (-2, .major)],
                [(0, .minor), (-2, .major), (-4, .major), (-5, .minor)]
            ]
        } else {
            potentialKeys = [
                [(0, .major), (-5, .major), (-3, .minor), (5, .major)],
                [(0, .major), (0, .major), (-7, .minor), (-5, .major)]
            ]
        }
        keySequence = potentialKeys.randomElement()!
        
        let potentialKeys2: [[(Int, KeyType)]]
        if keyType == .minor {
            potentialKeys2 = [
                [(3, .major), (0, .minor), (-4, .major), (-2, .major)],
                [(-4, .major), (-2, .major), (0, .minor), (-2, .major)]
            ]
        } else {
            potentialKeys2 = [
                [(2, .minor), (0, .major), (-3, .minor), (0, .major)],
                [(-3, .minor), (-5, .major), (-7, .major), (-5, .major)]
            ]
        }
        keySequence2 = potentialKeys2.randomElement()!
        
        super.init(baseNote: baseNote, keyType: keyType, patternSize: patternSize, blockSize: blockSize)
    }
    
    func generatePattern() -> Pattern {
        let pattern = Pattern(rowCount: patternSize)
        
        var keySequence = (patternIndex % 8 >= 4) ? keySequence2 : self.keySequence
        
        for i in stride(from: 0, to: patternSize, by: blockSize) {
            let (key, keyType) = keySequence.removeFirst()
            let keyChord = Key(baseNote: self.key.baseNote + key, keyType: keyType)
            for (channel, generator) in generators {
                generator.applyNotes(channel: channel, pattern: pattern, rhythm: rhythm, beatBegin: i, beatLength: blockSize, rootKey: self.key, keyChord: keyChord)
            }
            
            keySequence.append((key, keyType))
        }
        
        patterns.append(pattern)
        
        patternIndex += 1
        
        return pattern
    }
    
}
