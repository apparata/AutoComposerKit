import Foundation

class MainStrategy: Strategy {
    
    // Input parameters
    private let key: Key
    private let patternSize: Int
    private let blockSize: Int
    private let generators: [[ChannelID]: Generator]

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
        generators: [[ChannelID]: Generator]
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

        self.keySequence = Self.generateKeySequence(&randomizer)
        self.keySequence2 = Self.generateKeySequence(&randomizer)
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
    
    private static func generateKeySequence(_ randomizer: inout RandomNumberGenerator) -> [Key] {
                
        let keySequence: [Key] = [
            randomKey(&randomizer),
            randomKey(&randomizer),
            randomKey(&randomizer),
            randomKey(&randomizer)
        ]

        return keySequence
    }
    
    private static func randomKey(_ randomizer: inout RandomNumberGenerator) -> Key {
        // swiftlint:disable force_unwrapping
        let baseNote = [
            0, -4, 5, -2, 0, -2, -4, -5,
            0, -5, -3, 5, 0, 0, -7, -5,
            3, 0, -4, -2, -4, -2, 0, -2,
            2, 0, -3, 0, -3, -5, -7, -5
        ].randomElement(using: &randomizer)!
        // swiftlint:enable force_unwrapping

        // swiftlint:disable force_unwrapping
        let keyType: KeyType = [
            .harmonicMinor, .naturalMinor, .melodicMinor,
            .major, .pentatonicMinor, .pentatonicMajor
        ].randomElement(using: &randomizer)!
        // swiftlint:enable force_unwrapping

        return Key(baseNote, keyType)
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
