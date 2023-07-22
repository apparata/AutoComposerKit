//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

typealias PatternIndex = Int

enum Instrument: Int {
    case guitar = 0
    case bass = 1
    case kickDrum = 2
    case hihatClosed = 3
    case hihatOpen = 4
    case snareDrum = 5
}

public class Track {
    
    var orders: [PatternIndex] = []
    
    var patterns: [Pattern] = []
    
    private init() {
        
    }
    
    func add(pattern: Pattern) -> PatternIndex {
        patterns.append(pattern)
        return patterns.count - 1
    }
    
    func add(order: PatternIndex) {
        orders.append(order)
    }
    
    public static func generate(seed: Int = Int.random(in: 0...0xFFFFFF)) -> Track {
        let track = Track()
        
        var randomizer = SeededRandomNumberGenerator(seed: seed)
        
        let baseNote = 12 + Int(Float.random(in: 50...(50 + 12 - 1), using: &randomizer))
        let keyType: KeyType = Float.random(in: 0...1, using: &randomizer) < 0.6 ? .naturalMinor : .major
        let patternSize = 128
        let blockSize = 32
        
        let strategy = MainStrategy(baseNote: baseNote, keyType: keyType, patternSize: patternSize, blockSize: blockSize, randomizer: &randomizer)
        strategy.add(generator: DrumsGenerator(randomizer: &randomizer))
        strategy.add(generator: AmbientMelodyGenerator(randomizer: &randomizer))
        strategy.add(generator: BassGenerator())
        
        let patternCount = 6
        
        for _ in 0..<patternCount {
            let pattern = strategy.generatePattern(randomizer: &randomizer)
            let patternIndex = track.add(pattern: pattern)
            track.add(order: patternIndex)
        }
        
        return track
    }
    
}
