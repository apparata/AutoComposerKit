//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation


class Strategy {
    
    let key: Key
    var usedChannelCount: Int
    var generators: [(Int, Generator)]
    var patterns: [Pattern] = []
    let patternSize: Int
    let blockSize: Int
    
    required init(baseNote: Int, keyType: KeyType, patternSize: Int, blockSize: Int, randomizer: inout SeededRandomNumberGenerator) {
        key = Key(baseNote: baseNote, keyType: keyType)
        usedChannelCount = 0
        generators = []
        self.patternSize = patternSize
        self.blockSize = blockSize
    }
    
    func add(generator: Generator) {
        generators.append((usedChannelCount, generator))
        usedChannelCount += generator.size
    }
}
