import Foundation


typealias Metadata = (aggregationType: UInt32, maxRetention: UInt32, xFilesFactor: Float32, archiveCount: UInt32)
typealias ArchiveInfo = (offset: UInt32, secondsPerPoint: UInt32, points: UInt32)
typealias Point = (timestamp: UInt32, value: Double)


let args = CommandLine.arguments
guard
    args.count > 1,
    let handler = InputStream(fileAtPath: args[1])
else {
    exit(1)
}


handler.open()
defer {
    handler.close()
}

func crash(_ handler: Stream) -> Never {
    if let err = handler.streamError {
        print("Stream Error: \(err)")
    }
    print("Stream status: \(handler.streamStatus)")
    fatalError("CRASH")
}

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
func readMetadata(_ handler: InputStream) -> Metadata {
  // metadata: aggregationType, maxRetention, xff, archiveCount
  /** aggregationType
    1: 'average',
    2: 'sum',
    3: 'last',
    4: 'max',
    5: 'min',
    6: 'avg_zero',
    7: 'absmax',
    8: 'absmin'
  */
  // 0 <= xff <= 1
  let md1: UInt32 = readInt(handler)
  let md2: UInt32 = readInt(handler)
  let md3: Float32 = readFloat(handler)
  let md4: UInt32 = readInt(handler)

  return (aggregationType: md1, maxRetention: md2, xFilesFactor: md3, archiveCount: md4)
}

func readArchiveInfo(_ handler: InputStream) -> ArchiveInfo {
  let md1: UInt32 = readInt(handler)
  let md2: UInt32 = readInt(handler)
  let md3: UInt32 = readInt(handler)

  return (offset: md1, secondsPerPoint: md2, points: md3)
}

func readPoints(_ handler: InputStream, _ count: UInt32) -> [Point] {
    var points = [Point]()

    for _ in 0..<count {
        let ts = readInt(handler)
        let d = readDouble(handler)

        points.append( (timestamp: ts, value: d) ) 
    }

    return points
}

let metadata = readMetadata(handler)
var archiveInfo: [ArchiveInfo] = []
for _ in 0..<metadata.archiveCount {
    let ai = readArchiveInfo(handler)
    archiveInfo.append(ai)
}


let pts = archiveInfo
    .map { readPoints(handler, $0.points) }
    .flatMap {$0} 

// let pts1 = readPoints(handler, archiveInfo[0].points)
// let pts2 = readPoints(handler, archiveInfo[1].points)

// print("Metadata: \(metadata)")
// print("Archive Info: \(archiveInfo)")
// print("Points[0]: \(pts1.count)")
// print("Points[1]: \(pts2.count)")

// --- //



pts.forEach { p in
  print("\(p.timestamp):\(p.value)")
}

