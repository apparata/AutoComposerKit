import Foundation
import MIDISequencer

public typealias InstrumentNote = UInt8

public struct MIDIInstrument {
    public let preset: MIDIPreset
    
    /// Only used for one-note instruments such as drums.
    public let note: InstrumentNote?
    
    public init(preset: MIDIPreset, note: InstrumentNote? = nil) {
        self.preset = preset
        self.note = note
    }
}

public class TrackMIDIfier {
    
    /// Example:
    /// ```
    /// Configuration(instruments: [
    ///     "hihat": MIDIInstrument(preset: .init(bank: msb: 120, lsb: 0), program: 16, note: 42),
    ///     "kick": MIDIInstrument(preset: .init(bank: msb: 120, lsb: 0), program: 16, note: 36),
    ///     "snare": MIDIInstrument(preset: .init(bank: msb: 120, lsb: 0), program: 16, note: 38),
    ///     "bass": MIDIInstrument(preset: MIDIPreset(bank: (msb: 0, lsb: 0), program: 32)),
    ///     "piano", MIDIInstrument(preset: MIDIPreset(bank: (msb: 0, lsb: 0), program: 0)),
    ///     "guitar": MIDIInstrument(preset: MIDIPreset(bank: (msb: 0, lsb: 0), program: 24))
    /// ])
    /// ```
    public struct Configuration {
        public let instruments: [ChannelID: MIDIInstrument]
        
        public init(instruments: [ChannelID: MIDIInstrument]) {
            self.instruments = instruments
        }
        
        func instrument(for channelID: ChannelID) -> MIDIInstrument {
            instruments[channelID] ?? MIDIInstrument(preset: MIDIPreset(bank: (msb: 0, lsb: 0), program: 24))
        }
    }
    
    public static func makeSequence(track: Track, configuration: Configuration) throws -> MIDISequence {
    
        let sequence = try MIDISequence(bpm: MIDIBeatsPerMinute(track.bpm))

        let noteDuration: MIDIBeat = 2.0
        let timeStep: Float64 = 0.2
        
        var time = 1.0
        
        var midiTracks: [ChannelID: (midiChannel: UInt8, track: MIDITrack)] = [:]
        
        var midiChannel: UInt8 = 0
        for (channelIDs, _) in track.channelGroups {
            for channelID in channelIDs {
                let midiTrack = try sequence.addTrack()
                midiTracks[channelID] = (midiChannel: midiChannel, track: midiTrack)
                let instrument = configuration.instrument(for: channelID)
                midiTrack.add(preset: instrument.preset, on: midiChannel, at: 1.0)
                midiChannel += 1
            }
        }
        
        for patternID in track.order {
            guard let pattern = track.patterns[patternID] else {
                continue
            }
            
            patternLoop: for i in 0..<pattern.rows.count {
                let row = pattern.rows[i]
                
                // Check if skip to next pattern
                for (_, command) in row.channels {
                    if command.command.isNoteCut {
                        continue patternLoop
                    }
                }
                
                for (channelID, command) in row.channels {
                                        
                    if command.command.isNotIgnore {
                        print("Pattern \(i): note \(command.command.value) vol \(command.volume)")
                          
                        let instrument = configuration.instrument(for: channelID)

                        let midiNote: UInt8
                        if let note = instrument.note {
                            midiNote = note
                        } else {
                            // I guess we are lowering one octave?
                            midiNote = UInt8(command.command.value - 12)
                        }
                        
                        // swiftlint:disable:next force_unwrapping
                        let (midiChannel, track) = midiTracks[channelID]!
                                                
                        let maxVelocity: Int = 127
                        let velocity = UInt8(Float(maxVelocity) * Float(command.volume) / 255.0)
                        let note = MIDINote(channel: midiChannel, note: midiNote, velocity: velocity, releaseVelocity: 0, duration: noteDuration)
                        track.add(note: note, at: time)
                    }
                }
                 
                time += Float64(timeStep)
            }
            
        }
        
        return sequence
    }
    
}
