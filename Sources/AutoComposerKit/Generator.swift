//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

protocol Generator {
    var size: Int { get }
    func applyNotes(channel: Int, pattern: Pattern, rhythm: [Int], beatBegin: Int, beatLength: Int, rootKey: Key, keyChord: Key)
}
