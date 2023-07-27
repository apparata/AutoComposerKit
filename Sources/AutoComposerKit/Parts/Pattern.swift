import Foundation

/// Pattern contains rows, where each row has a command per channel.
///
/// ```
/// Track
///   ├ Order ┄┄┄┐
///   │          ┊
///   └ Pattern <┘
///     │
///     └ Row
///       │
///       └ Command
/// ```
public class Pattern {
    
    /// X rows, 5 columns, each entry:
    /// - note = 253 (0xFD)
    /// - instrument = 0
    /// - volume = 255 (0xFF)
    /// - effect type = 0
    /// - effect parameter = 0
        
    var rows: [Row]
    
    init(rowCount: Int, channelIDGroups: Set<ChannelIDGroup>) {
        let defaultChannelEntry = Command(command: .ignore)

        var channelEntries: [ChannelID: Command] = [:]
        
        for channelIDGroup in channelIDGroups {
            for channelID in channelIDGroup {
                channelEntries[channelID] = defaultChannelEntry
            }
        }
        
        let defaultRow = Row(channels: channelEntries)
        
        rows = []
        
        for _ in 0..<rowCount {
            rows.append(defaultRow)
        }
    }
}
