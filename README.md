# rx_pack
Dart streams extension for working with streams in a more convenient way.

## Getting Started

- Add a dev dependency in your pubspec.yaml

```yaml
dev_dependencies:
  rx_pack: ^1.0.1
```
### Extensions:
#### bufferTimeDelay

Input Stream:   A----B--C-------D------E----F--G---|
|       |        |         |
v       v        v         v
Timers Start:     [Initial][Duration][Duration][End]
Flush Times (s):    2        7        12       End

Output Stream:  -----[A]-------[B,C]------[D,E,F]---[G]|