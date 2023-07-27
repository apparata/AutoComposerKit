import Foundation

public typealias PatternID = Int

/// Generated music track
public class Track {
    
    /// The generated note patterns.
    let patterns: [PatternID: Pattern]
    
    /// The order in which to play the patterns.
    let order: [PatternID]

    /// The channels to generate patterns for.
    public let channelGroups: [ChannelIDGroup: ChannelGroup]

    public let bpm: Int
    
    private init(bpm: Int, patterns: [PatternID: Pattern], order: [PatternID], channelGroups: [ChannelIDGroup: ChannelGroup]) {
        self.patterns = patterns
        self.order = order
        self.channelGroups = channelGroups
        self.bpm = bpm
    }
    
    /// Generates a track
    public static func generate(specification: TrackSpecification = .default) -> Track {
        var randomizer: RandomNumberGenerator = SystemRandomNumberGenerator()
        let track = generate(randomizer: &randomizer, specification: specification)
        return track
    }

    /// Generates a track with a given seed
    public static func generate(seed: Int = Int.random(in: 0...0xFFFFFF), specification: TrackSpecification = .default) -> Track {
        var randomizer: RandomNumberGenerator = SeededRandomNumberGenerator(seed: seed)
        let track = generate(randomizer: &randomizer, specification: specification)
        return track
    }
    
    /// Generates a track with a give random number generator
    public static func generate(randomizer: inout RandomNumberGenerator, specification: TrackSpecification = .default) -> Track {
        
        let baseNote = 12 + Int(Float.random(in: 50...(50 + 12 - 1), using: &randomizer))
        let keyType: KeyType = Float.random(in: 0...1, using: &randomizer) < 0.6 ? .naturalMinor : .major
        let patternSize = 128
        let blockSize = 32
        
        let generators: [ChannelIDGroup: any Generator] = Dictionary(
            uniqueKeysWithValues: specification.channelGroups.map { channelGroup in
            switch channelGroup.type {
            case .drums: return (channelGroup.ids, DrumsGenerator(&randomizer))
            case .bass: return (channelGroup.ids, BassGenerator())
            case .ambient: return (channelGroup.ids, AmbientGenerator(&randomizer))
            }
        })
        
        let strategy = MainStrategy(
            baseNote: baseNote,
            keyType: keyType,
            patternSize: patternSize,
            blockSize: blockSize,
            randomizer: &randomizer,
            generators: generators)
        
        let state = PatternGenerator(strategy: strategy)
        for (patternID, channelIDGroups) in specification.patterns {
            state.generatePattern(id: patternID, channelIDGroups: channelIDGroups, &randomizer)
        }
        
        var channelGroups: [ChannelIDGroup: ChannelGroup] = [:]
        for channelGroup in specification.channelGroups {
            channelGroups[channelGroup.ids] = channelGroup
        }
                
        let track = Track(
            bpm: specification.bpm,
            patterns: state.patterns,
            order: specification.order,
            channelGroups: channelGroups)
        
        return track
    }
}
