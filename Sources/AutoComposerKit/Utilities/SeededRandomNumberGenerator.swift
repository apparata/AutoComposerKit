import Foundation

public struct SeededRandomNumberGenerator: RandomNumberGenerator {

    init(seed: Int) {
        srand48(seed)
    }
    
    public func next() -> UInt64 {
        // drand48() returns a Double, transform to UInt64
        return withUnsafeBytes(of: drand48()) { bytes in
            bytes.load(as: UInt64.self)
        }
    }
}
