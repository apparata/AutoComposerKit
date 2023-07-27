import Foundation

class PatternGenerator {

    private(set) var patterns: [PatternID: Pattern]

    private let strategy: Strategy
    
    init(strategy: Strategy) {
        self.strategy = strategy
        self.patterns = [:]
    }
    
    func generatePattern(id: PatternID, channelIDGroups: Set<ChannelIDGroup>, _ randomizer: inout SeededRandomNumberGenerator) {
        let pattern = strategy.generatePattern(id: id, channelIDGroups: channelIDGroups, &randomizer)
        patterns[id] = pattern
    }
}
