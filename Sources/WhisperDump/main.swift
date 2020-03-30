import Foundation


let args = CommandLine.arguments
guard
  args.count > 1,
  let handler = InputStream(fileAtPath: args[1])
else {
  print("Usage: WhisperData <path-to-whisper.wsp>")
  exit(1)
}


handler.open()
defer {
  handler.close()
}


// read whisper data
let metadata = readMetadata(handler)

var archiveInfo: [ArchiveInfo] = []
for _ in 0..<metadata.archiveCount {
  let ai = readArchiveInfo(handler)
  archiveInfo.append(ai)
}

let pts = archiveInfo
  .map { readPoints(handler, $0.points) }
  .flatMap {$0} 

// dump data points to stdout
pts.forEach { p in
  print("\(p.timestamp):\(p.value)")
}