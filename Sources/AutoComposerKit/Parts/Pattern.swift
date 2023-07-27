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
    
    init(rowCount: Int, channelIDGroups: [ChannelIDGroup]) {
        var channelEntries: [ChannelID: Command] = [:]
        
        for channelIDGroup in channelIDGroups {
            for channelID in channelIDGroup {
                // Default command
                channelEntries[channelID] = Command(command: .ignore)
            }
        }
        
        rows = []
        
        for _ in 0..<rowCount {
            // Default row
            rows.append(Row(channels: channelEntries))
        }
    }
}
