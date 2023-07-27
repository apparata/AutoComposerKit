import Foundation

public typealias ChannelID = String

public enum ChannelType: Equatable {
    case drums
    case bass
    case ambient
}

public class ChannelGroup {
    
    public let ids: ChannelIDGroup
    public let type: ChannelType
    
    public init(ids: ChannelIDGroup, type: ChannelType) {
        self.ids = ids
        self.type = type
    }
}
 
extension ChannelGroup: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        for id in ids {
            hasher.combine(id)
        }
    }
    
    public static func == (lhs: ChannelGroup, rhs: ChannelGroup) -> Bool {
        lhs.ids == rhs.ids && lhs.type == rhs.type
    }
}
