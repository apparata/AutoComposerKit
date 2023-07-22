//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

enum KeyType {
    case harmonicMinor
    case naturalMinor
    case melodicMinor
    case major
    case pentatonicMinor
    case pentatonicMajor
}

class Key {
        
    private static func scaleToMask(_ scale: String) -> [Bool] {
        let notes = scale.components(separatedBy: .whitespaces)
        let mask: [Bool] = [
            notes.contains("C"),
            notes.contains("C♯") || notes.contains("D♭"),
            notes.contains("D"),
            notes.contains("D♯") || notes.contains("E♭"),
            notes.contains("E"),
            notes.contains("F"),
            notes.contains("F♯") || notes.contains("G♭"),
            notes.contains("G"),
            notes.contains("G♯") || notes.contains("A♭"),
            notes.contains("A"),
            notes.contains("A♯") || notes.contains("B♭"),
            notes.contains("B"),
        ]
        return mask
    }

    // C C♯/D♭ D D♯/E♭ E F F♯/G♭ G G#/A♭ A A♯/B♭ B
    private static let masks: [KeyType: [Bool]] = [
        .harmonicMinor: scaleToMask("C D E♭ F G A♭ B"),
        .naturalMinor: scaleToMask("C D E♭ F G A♭ B♭"),
        .melodicMinor: scaleToMask("C D E♭ F G A B"),
        .major: scaleToMask("C D E F G A B"),
        .pentatonicMinor: scaleToMask("C E♭ F G B♭"),
        .pentatonicMajor: scaleToMask("C D E G A")
    ]
    
    var mask: [Bool] {
        // swiftlint:disable:next force_unwrapping
        return Key.masks[keyType]!
    }
    
    let baseNote: Int
    
    let keyType: KeyType
    
    init(baseNote: Int, keyType: KeyType) {
        self.baseNote = baseNote
        self.keyType = keyType
    }
    
    func hasNote(note: Int) -> Bool {
        // The remastered python version only has `note - baseNote` here?
        let index = note - baseNote < 0 ? baseNote - note : note - baseNote
        return mask[index % 12]
    }
}
