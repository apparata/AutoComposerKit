//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

class AmbientMelodyGenerator: Generator {
    
    private let motifProspects: [[Int]] = [
        // 1-steps
        [1],
        [2],
        [3],
        
        // 2-steps
        [1, 3],
        [2, 3],
        [2, 4],
        
        // niceties
        [5, 7],
        [5, 12],
        [7, 12],
        [7],
        [5],
        [12],
        
        // 3-chords
        [3, 7],
        [4, 7],
        
        // 4-chords
        [3, 7, 10],
        [3, 7, 11],
        [4, 7, 10],
        [4, 7, 11],
        
        // turns and stuff
        [1, 0],
        [2, 0],
        [1, -1, 0],
        [1, -2, 0],
        [2, -1, 0],
        [2, -2, 0]
    ]
    
    let beatRow: Int = Int(pow(2.0, Double.random(in: 2...3)))
    var lq = 60
    var l_note = -1
    var motifQueue: [Int] = []
    var noteQueue: [Int] = []
    
    var size: Int {
        return 1
    }
    
    func applyNotes(channel: Int, pattern: Pattern, rhythm: [Int], beatBegin: Int, beatLength: Int, rootKey: Key, keyChord: Key) {
        let beatEnd = beatBegin + beatLength
        
        let base = keyChord.baseNote
        if beatBegin == 0 {
            lq = base
            l_note = -1
            motifQueue = []
            noteQueue = []
        }
        
        pattern.data[beatBegin][channel] = [lq, Instrument.guitar.rawValue, 255, 0, 0]
        noteQueue.append(beatBegin)
        
        var stabbing = false
        
        var row = beatBegin
        while row < beatEnd {
            if pattern.data[row][channel][0] != 253 {
                noteQueue.append(row)
                row += beatRow
                continue
            }
            
            //var q = 60 // should this be lq??
            
            if motifQueue.count > 0 {
                if stabbing || Float.random(in: 0...1) < 0.9 {
                    let note = motifQueue.removeFirst()
                    l_note = note
                    pattern.data[row][channel] = [note, Instrument.guitar.rawValue, 255, 0, 0]
                    noteQueue.append(row)
                    
                    if motifQueue.isEmpty {
                        lq = note
                    }
                    
                    if Float.random(in: 0...1) < 0.2 || stabbing {
                        row += beatRow / 2
                        stabbing = !stabbing
                    } else {
                        row += beatRow
                    }
                } else {
                    row += beatRow
                }
            } else if (row - beatBegin >= 2 * beatRow) && (Float.random(in: 0...1) < 0.3) {
                let upperLimit: Int = min(10, row / (beatRow / 2))
                let backStep = Int.random(in: 3...upperLimit) * (beatRow / 2)
                
                for _ in 0..<backStep {
                    if row - beatBegin >= beatLength {
                        break
                    }
                    pattern.data[row][channel] = pattern.data[row - backStep][channel]
                    let note = pattern.data[row][channel][0]
                    if note != 253 {
                        l_note = note
                        lq = note
                    }
                    row += 1
                }
            } else {
                if noteQueue.count > 5 {
                    noteQueue = Array<Int>(noteQueue.suffix(5))
                }
                
                var motif: [Int] = []
                var rb_note: Int = 0
                
                while true {
                    var kk = false
                    while true {
                        let rb_index = noteQueue.randomElement()!
                        rb_note = pattern.data[rb_index][channel][0]
                        
                        if l_note != -1 && abs(rb_note - l_note) > 12 {
                            continue
                        }
                        
                        break
                    }
                    
                    motif = []
                    
                    for _ in 0..<20 {
                        motif = motifProspects.randomElement()!
                        
                        let threshold = l_note != -1 ? (8.0 + Double(l_note - base)) / 8.0 : 0.5
                        let down: Bool = Double.random(in: 0...1) < threshold
                        
                        if down {
                            motif = motif.map {
                                rb_note - $0
                            }
                        } else {
                            motif = motif.map {
                                rb_note + $0
                            }
                        }
                        
                        if l_note == motif[0] {
                            continue
                        }
                        
                        var k = true
                        for v in motif {
                            if !keyChord.hasNote(note: v) && rootKey.hasNote(note: v) {
                                k = false
                                break
                            }
                        }
                        
                        if k {
                            kk = true
                            break
                        }
                    }
                    
                    if kk {
                        break
                    }
                }
                
                if rb_note != l_note {
                    motif = [rb_note] + motif
                }
                
                motifQueue += motif
            }
        }
    }
}
