# WhisperDump

A basic [Whisper database](https://graphite.readthedocs.io/en/latest/whisper.html) [dumper](https://github.com/graphite-project/whisper/blob/master/bin/whisper-dump.py) written in pure Swift

## Usage

```swift
swift package update
swift build
swift run WhisperDump <whisper-file.wsp>
```

It logs out all data points with their time in UNIX timestamp
