

// see: https://github.com/graphite-project/whisper/blob/60c8b9bab5dff6bdafca6880aafca5fcadc0aa77/whisper.py#L120
public enum AggregationType: UInt32 {
  case average = 1
  case sum = 2
  case last = 3
  case max = 4
  case min = 5
  case avg_zer = 6
  case absmax = 7
  case absmin = 8
}