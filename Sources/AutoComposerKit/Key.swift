//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

enum KeyType {
    case minor
    case major
}

class Key {
    
    private static let masks: [KeyType: [Bool]] = [
        .minor: [true, false, true, true, false, true, false, true, true, false, true, false],
        .major: [true, false, true, false, true, true, false, true, false, true, false, true]
    ]
    
    var mask: [Bool] {
        return Key.masks[keyType]!
    }
    
    let baseNote: Int
    
    let keyType: KeyType
    
    init(baseNote: Int, keyType: KeyType) {
        self.baseNote = baseNote
        self.keyType = keyType
    }
    
    func hasNote(note: Int) -> Bool {
        let index = note - baseNote < 0 ? baseNote - note : note - baseNote
        return mask[index % 12]
    }
}

