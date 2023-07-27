import Foundation

protocol Strategy {
    /// Restrict generated pattern to only the specified generators.
    func generatePattern(
        id patternID: PatternID,
        channelIDGroups: [ChannelIDGroup],
        _ randomizer: inout RandomNumberGenerator
    ) -> Pattern
}
