//
//  Copyright © 2017 Apparata AB. All rights reserved.
//

import Foundation
import MIDISequencer

public class TrackMIDIfier {
    
    public typealias Note = UInt8
    public typealias Program = UInt8
    
    public struct Configuration {
        public let kickDrum: Note
        public let snareDrum: Note
        public let hiHatClosed: Note
        public let hiHatOpen: Note
        
        public let drums: Program
        public let bass: Program
        public let lead: Program
        
        public init(kickDrum: Note = 36,
                    snareDrum: Note = 38,
                    hiHatClosed: Note = 42,
                    hiHatOpen: Note = 46,
                    drums: Program = 127,
                    bass: Program = 24,
                    lead: Program = 24) {
            self.kickDrum = kickDrum
            self.snareDrum = snareDrum
            self.hiHatClosed = hiHatClosed
            self.hiHatOpen = hiHatOpen
            self.drums = drums
            self.bass = bass
            self.lead = lead
        }
    }
    
    public static func makeSequence(track: Track, configuration: Configuration = Configuration()) throws -> MIDISequence {
    
        let sequence = try MIDISequence(bpm: 120)
        
        let noteDuration: MIDIBeat = 2.0
        let timeStep: Float64 = 0.2
        
        var time = 1.0
        
        var tracks = [MIDITrack]()
        for trackIndex in 0..<5 {
            let track = try sequence.addTrack()
            
            switch trackIndex {
            case 0, 1, 2:
                track.add(program: configuration.drums, on: UInt8(trackIndex), at: 1.0)
            case 3: // Guitar
                track.add(program: configuration.lead, on: UInt8(trackIndex), at: 1.0)
            case 4: // Bass
                track.add(program: configuration.bass, on: UInt8(trackIndex), at: 1.0)
            default:
                break
            }
            
            tracks.append(track)
        }
        
        for patternIndex in track.orders {
            let pattern = track.patterns[patternIndex]
            
            patternLoop: for i in 0..<pattern.data.count {
                let row = pattern.data[i]
                
                // Check if skip to next pattern
                for trackIndex in 0..<5 {
                    let channel = row[trackIndex]
                    if channel[0] == 254 {
                        continue patternLoop
                    }
                }
                
                for trackIndex in 0..<5 {
                    
                    let channel = row[trackIndex]
                    
                    if channel[0] != 253 {
                        print("\(i): note \(channel[0]) instr \(channel[1]) vol \(channel[2]) fx \(channel[3]) param \(channel[4])")
                        
                        let midiNote: UInt8
                        switch channel[1] {
                        case Instrument.kickDrum.rawValue:
                            midiNote = configuration.kickDrum
                        case Instrument.snareDrum.rawValue:
                            midiNote = configuration.snareDrum
                        case Instrument.hihatClosed.rawValue:
                            midiNote = configuration.hiHatClosed
                        case Instrument.hihatOpen.rawValue:
                            midiNote = configuration.hiHatOpen
                        case Instrument.bass.rawValue:
                            midiNote = UInt8(12 + channel[0] - 24)
                        case Instrument.guitar.rawValue:
                            midiNote = UInt8(12 + channel[0] - 24)
                        default:
                            fatalError("Should not happen")
                            break
                        }
                        
                        let maxVelocity: Int = 127
                        let velocity = UInt8(Float(maxVelocity) * Float(channel[2]) / 255.0)
                        let note = MIDINote(channel: UInt8(trackIndex), note: midiNote, velocity: velocity, releaseVelocity: 0, duration: noteDuration)
                        tracks[trackIndex].add(note: note, at: time)
                    }
                }
                time += Float64(timeStep)
            }
            
        }
        
        return sequence
    }
    
}
