import Foundation

/// Each row has a command per channel
class Row {
    private(set) var channels: [ChannelID: Command]
    
    internal init(channels: [ChannelID: Command]) {
        self.channels = channels
    }
    
    func channel(_ channelID: ChannelID) -> Command {
        // swiftlint:disable:next force_unwrapping
        channels[channelID]!
    }
    
    func setCommand(_ command: Command, on channel: ChannelID) {
        channels[channel] = command
    }
}
