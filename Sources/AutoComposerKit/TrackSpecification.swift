import Foundation

public enum TrackError: Error {
    case invalidTrackSpecification
}

public typealias ChannelIDGroup = [ChannelID]

public struct TrackSpecification {
    public let bpm: Int
    public let channelGroups: [ChannelGroup]
    public let patterns: [PatternID: [ChannelIDGroup]]
    public let order: [PatternID]
    
    public init(
        bpm: Int,
        channelGroups: [ChannelIDGroup: ChannelType],
        patterns: [PatternID: [ChannelIDGroup]],
        order: [PatternID]
    ) throws {
        self.bpm = bpm
        self.channelGroups = channelGroups.map { idGroup, type in
            ChannelGroup(ids: idGroup, type: type)
        }
        self.patterns = patterns
        self.order = order
    }
}

extension TrackSpecification {
    public static var `default`: TrackSpecification {
        // swiftlint:disable:next all
        try! TrackSpecification(
            bpm: 120,
            channelGroups: [
                ["hihat", "kick", "snare"]: .drums,
                ["bass"]: .bass,
                ["piano"]: .ambient,
                ["guitar"]: .ambient
            ],
            patterns: [
                0: [["hihat", "kick", "snare"]],
                1: [["hihat", "kick", "snare"], ["bass"], ["piano"]],
                2: [["hihat", "kick", "snare"], ["bass"], ["guitar"]],
                3: [["hihat", "kick", "snare"], ["bass"], ["piano"], ["guitar"]],
                4: [["hihat", "kick", "snare"], ["bass"], ["piano"], ["guitar"]],
                5: [["hihat", "kick", "snare"], ["bass"]],
                6: [["hihat", "kick", "snare"], ["bass"], ["piano"], ["guitar"]]
            ],
            order: [
                0, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6
            ])
    }
}
