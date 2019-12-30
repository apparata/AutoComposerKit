//
//  Copyright © 2017 Apparata AB. All rights reserved.
//

import Foundation
import MIDISequencer

public class TrackMIDIfier {
    
    public static func makeSequence(track: Track) throws -> MIDISequence {
    
        let sequence = try MIDISequence(bpm: 120)
        
        let noteDuration: MIDIBeat = 2.0
        let timeStep: Float64 = 0.2
        
        var time = 1.0
        
        var tracks = [MIDITrack]()
        for trackIndex in 0..<5 {
            let track = try sequence.addTrack()
            
            switch trackIndex {
            case 0, 1, 2:
                track.add(program: 127, on: UInt8(trackIndex), at: 1.0)
            case 3: // Guitar
                track.add(program: 24, on: UInt8(trackIndex), at: 1.0)
            case 4: // Bass
                track.add(program: 24, on: UInt8(trackIndex), at: 1.0)
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
                            midiNote = 36
                        case Instrument.snareDrum.rawValue:
                            midiNote = 38
                        case Instrument.hihatClosed.rawValue:
                            midiNote = 42
                        case Instrument.hihatOpen.rawValue:
                            midiNote = 46
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
