import Foundation


// crash function 
func crash(_ handler: Stream) -> Never {
    if let err = handler.streamError {
        print("Stream Error: \(err)")
    }
    print("Stream status: \(handler.streamStatus)")
    fatalError("CRASH")
}


//
// atomic readers
//


func readInt(_ handler: InputStream) -> UInt32 {
  let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
  let r = handler.read(uint8Pointer, maxLength: 4)
  guard r == 4 else {
    crash(handler)
  }
  let i = uint8Pointer.withMemoryRebound(to: UInt32.self, capacity: 1) { $0.pointee }
  return i.bigEndian
}


func readLong(_ handler: InputStream) -> UInt64 {
  let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
  let r = handler.read(uint8Pointer, maxLength: 8)
  guard r == 8 else {
    fatalError("CRASH")
  }
  let i = uint8Pointer.withMemoryRebound(to: UInt64.self, capacity: 1) { $0.pointee }
  return i.bigEndian
}


func readFloat(_ handler: InputStream) -> Float32 {
  return Float32(bitPattern: readInt(handler))
}


func readDouble(_ handler: InputStream) -> Double {
  return Double(bitPattern: readLong(handler))
}


//
// Data Structures in Whisper file
//


func readMetadata(_ handler: InputStream) -> Metadata {
  let md1: UInt32 = readInt(handler)
  let md2: UInt32 = readInt(handler)
  let md3: Float32 = readFloat(handler)
  let md4: UInt32 = readInt(handler)

  guard let at = AggregationType(rawValue: md1) else {
    crash(handler)
  }

  return Metadata(aggregationType: at, maxRetention: md2, xFilesFactor: md3, archiveCount: md4)
}


func readArchiveInfo(_ handler: InputStream) -> ArchiveInfo {
  let md1: UInt32 = readInt(handler)
  let md2: UInt32 = readInt(handler)
  let md3: UInt32 = readInt(handler)

  return ArchiveInfo(offset: md1, secondsPerPoint: md2, points: md3)
}


func readPoints(_ handler: InputStream, _ count: UInt32) -> [Point] {
    var points = [Point]()

    for _ in 0..<count {
        let ts = readInt(handler)
        let d = readDouble(handler)

        points.append( Point(timestamp: ts, value: d) ) 
    }

    return points
}
