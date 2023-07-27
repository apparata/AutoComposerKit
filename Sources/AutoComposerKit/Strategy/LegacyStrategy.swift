import Foundation

class LegacyStrategy: Strategy {

    // Input parameters
    private let key: Key
    private let patternSize: Int
    private let blockSize: Int
    private var generators: [ChannelIDGroup: Generator]
    
    // Generated values
    private let speed: Int
    private let rhythm: Rhythm
    private let keySequence: [Key]
    private let keySequence2: [Key]
    
    required init(
        baseNote: Int,
        keyType: KeyType,
        patternSize: Int,
        blockSize: Int,
        randomizer: inout RandomNumberGenerator,
        generators: [ChannelIDGroup: Generator]
    ) {
        // Input parameters
        
        self.key = Key(baseNote, keyType)
        self.patternSize = patternSize
        self.blockSize = blockSize
        self.generators = generators
        
        // Generated values
       
        self.speed = Self.generateSpeed(&randomizer)
        
        self.rhythm = Self.generateRhythm(
            speed: speed,
            patternSize: patternSize,
            &randomizer)
                
        self.keySequence = Self.generateKeySequence(keyType: keyType, &randomizer)
        self.keySequence2 = Self.generateKeySequence2(keyType: keyType, &randomizer)
    }
    
    private static func generateSpeed(_ randomizer: inout RandomNumberGenerator) -> Int {
        // swiftlint:disable:next force_unwrapping
        let power = [2, 3].randomElement(using: &randomizer)!
        let speed = Int(pow(2.0, Double(power)))
        return speed
    }
    
    private static func generateRhythm(speed: Int, patternSize: Int, _ randomizer: inout RandomNumberGenerator) -> Rhythm {
        let rhythmCycle: [Int] = [3] + Array<Int>(repeating: 0, count: speed - 1) + [1] + Array<Int>(repeating: 0, count: speed - 1)
        var rhythm: [Int] = []
        let cycleCount = patternSize / rhythmCycle.count
        for _ in 0..<cycleCount {
            rhythm.append(contentsOf: rhythmCycle)
        }
        return Rhythm(rows: rhythm)
    }
    
    private static func generateKeySequence(keyType: KeyType, _ randomizer: inout RandomNumberGenerator) -> [Key] {
        let potentialKeys: [[Key]]
        if keyType == .naturalMinor {
            potentialKeys = [
                [Key(0, .naturalMinor), Key(-4, .major), Key(5, .major), Key(-2, .major)],
                [Key(0, .naturalMinor), Key(-2, .major), Key(-4, .major), Key(-5, .naturalMinor)]
            ]
        } else {
            potentialKeys = [
                [Key(0, .major), Key(-5, .major), Key(-3, .naturalMinor), Key(5, .major)],
                [Key(0, .major), Key(0, .major), Key(-7, .naturalMinor), Key(-5, .major)]
            ]
        }
        // swiftlint:disable:next force_unwrapping
        let keySequence = potentialKeys.randomElement(using: &randomizer)!
        return keySequence
    }
    
    private static func generateKeySequence2(keyType: KeyType, _ randomizer: inout RandomNumberGenerator) -> [Key] {
        let potentialKeys2: [[Key]]
        if keyType == .naturalMinor {
            potentialKeys2 = [
                [Key(3, .major), Key(0, .naturalMinor), Key(-4, .major), Key(-2, .major)],
                [Key(-4, .major), Key(-2, .major), Key(0, .naturalMinor), Key(-2, .major)]
            ]
        } else {
            potentialKeys2 = [
                [Key(2, .naturalMinor), Key(0, .major), Key(-3, .naturalMinor), Key(0, .major)],
                [Key(-3, .naturalMinor), Key(-5, .major), Key(-7, .major), Key(-5, .major)]
            ]
        }
        // swiftlint:disable:next force_unwrapping
        let keySequence2 = potentialKeys2.randomElement(using: &randomizer)!
        return keySequence2
    }
    
    func generatePattern(
        id patternID: PatternID,
        channelIDGroups: [ChannelIDGroup],
        _ randomizer: inout RandomNumberGenerator
    ) -> Pattern {
        let pattern = Pattern(rowCount: patternSize, channelIDGroups: channelIDGroups)
        
        var keySequence = (patternID % 8 >= 4) ? keySequence2 : self.keySequence
        
        for i in stride(from: 0, to: patternSize, by: blockSize) {
            let key = keySequence.removeFirst()
            let keyChord = Key(self.key.baseNote + key.baseNote, key.keyType)
            for (channelIDs, generator) in generators {
                if channelIDGroups.contains(channelIDs) {
                    generator.applyNotes(
                        channels: channelIDs,
                        pattern: pattern,
                        rhythm: rhythm,
                        beatBegin: i,
                        beatLength: blockSize,
                        rootKey: self.key,
                        keyChord: keyChord,
                        &randomizer)
                }
            }
            
            keySequence.append(key)
        }
        
        return pattern
    }
}
