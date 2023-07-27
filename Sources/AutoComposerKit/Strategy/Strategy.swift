import Foundation

protocol Strategy {
    /// Restrict generated pattern to only the specified generators.
    func generatePattern(
        id patternID: PatternID,
        channelIDGroups: Set<ChannelIDGroup>,
        _ randomizer: inout SeededRandomNumberGenerator
    ) -> Pattern
}
