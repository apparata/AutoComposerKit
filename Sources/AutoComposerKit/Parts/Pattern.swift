//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

class Pattern {
    
    /// X rows, 5 columns, each entry:
    /// - note = 253 (0xFD)
    /// - instrument = 0
    /// - volume = 255 (0xFF)
    /// - effect type = 0
    /// - effect parameter = 0
    
    var data: [[[Int]]]
    
    init(rowCount: Int) {
        let defaultEntry = [253, 0, 255, 0, 0]
        let defaultRow = Array<[Int]>(repeating: defaultEntry, count: 5)
        data = []
        for _ in 0..<rowCount {
            data.append(defaultRow)
        }
    }
}
