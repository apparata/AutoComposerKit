import Foundation

typealias Note = Int

enum NoteCommand {
    /// 0 -> 119 (C-0 -> B-9)
    case playNote(Note)
    
    /// 255 (???)
    case noteOff
    
    /// 254 (Skip to next pattern)
    case noteCut
    
    /// 253 (Ignore this command)
    case ignore
    
    /// Others
    case noteFade(Note)
    
    init(note: Note) {
        switch note {
        case 0...119: self = .playNote(note)
        case 255: self = .noteOff
        case 254: self = .noteCut
        case 253: self = .ignore
        default: self = .noteFade(note)
        }
    }
    
    var isPlayNote: Bool {
        if case .playNote = self {
            return true
        }
        return false
    }
    
    var isNoteOff: Bool {
        if case .noteOff = self {
            return true
        }
        return false
    }
    
    var isNoteCut: Bool {
        if case .noteCut = self {
            return true
        }
        return false
    }
    
    var isIgnore: Bool {
        if case .ignore = self {
            return true
        }
        return false
    }
    
    var isNotIgnore: Bool {
        !isIgnore
    }
    
    var value: Note {
        switch self {
        case .playNote(let note): return note
        case .noteOff: return 255
        case .noteCut: return 254
        case .ignore: return 253
        case .noteFade(let note): return note
        }
    }
}

/// A command has a note to be played with a specific instrument and volume.
class Command {
    var command: NoteCommand
    var volume: Int
    
    internal init(
        command: NoteCommand = .playNote(60),
        volume: Int = 255
    ) {
        self.command = command
        self.volume = volume
    }
}
