

//
// Metadata section of Whisper Database
//
public struct Metadata {
    let aggregationType: AggregationType
    let maxRetention: UInt32

    // number between 0 and 1
    let xFilesFactor: Float32

    // number of archive info sections
    let archiveCount: UInt32
}