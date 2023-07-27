
# AutoComposerKit

## License

See the UNLICENSE file for licensing information.

## Usage

Here is an example:

```swift
let track = Track.generate(
    specification: try TrackSpecification(
        bpm: 120,
        channelGroups: [
            ["hihat", "kick", "snare"]: .drums,
            ["bass"]: .bass,
            ["piano"]: .ambient,
            ["guitar"]: .ambient
        ],
        patterns: [
            0: [["hihat", "kick", "snare"]],
            1: [["hihat", "kick", "snare"], ["bass"], ["piano"]],
            2: [["hihat", "kick", "snare"], ["bass"], ["guitar"]],
            3: [["hihat", "kick", "snare"], ["bass"], ["piano"], ["guitar"]],
            4: [["hihat", "kick", "snare"], ["bass"], ["piano"], ["guitar"]],
            5: [["hihat", "kick", "snare"], ["bass"]],
            6: [["hihat", "kick", "snare"], ["bass"], ["piano"], ["guitar"]]
        ],
        order: [
            0, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6
        ]))

let config = TrackMIDIfier.Configuration(instruments: [
    "hihat": MIDIInstrument(preset: .init(bank: (msb: 120, lsb: 0), program: 16), note: 42),
    "kick": MIDIInstrument(preset: .init(bank: (msb: 120, lsb: 0), program: 16), note: 36),
    "snare": MIDIInstrument(preset: .init(bank: (msb: 120, lsb: 0), program: 16), note: 38),
    "bass": MIDIInstrument(preset: MIDIPreset(bank: (msb: 0, lsb: 0), program: 32)),
    "piano": MIDIInstrument(preset: MIDIPreset(bank: (msb: 0, lsb: 0), program: 0)),
    "guitar": MIDIInstrument(preset: MIDIPreset(bank: (msb: 0, lsb: 0), program: 24))
])

let sequence = try TrackMIDIfier.makeSequence(track: track, configuration: config)

try sequence.save(to: "/tmp/test.mid")

// Or serialize as data for use with AVMidiPlayer
let data = try sequence.serialize()
```
