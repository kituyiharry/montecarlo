
### Usage

run `dune build` to generate the binary in the build directory. then use the
`NDOMS` environment variable to vary the _domains_ used.


### Sample results

```
num_domains: 8
Single Thread

Exec: 0.000031 seconds  Size: 64        Res: 3.437500
Exec: 0.000173 seconds  Size: 512       Res: 2.992188
Exec: 0.000764 seconds  Size: 4096      Res: 3.129883
Exec: 0.007090 seconds  Size: 32768     Res: 3.133301
Exec: 0.038489 seconds  Size: 262144    Res: 3.139206
Exec: 0.171714 seconds  Size: 2097152   Res: 3.142467
Exec: 1.377226 seconds  Size: 16777216  Res: 3.141593
Exec: 19.494536 seconds Size: 134217728 Res: 3.141455

Multi Thread FOR_REDUCE

Exec: 0.000025 seconds  Size: 64        Res: 3.062500
Exec: 0.000592 seconds  Size: 512       Res: 3.132812
Exec: 0.000639 seconds  Size: 4096      Res: 3.127930
Exec: 0.001308 seconds  Size: 32768     Res: 3.150513
Exec: 0.017099 seconds  Size: 262144    Res: 3.148254
Exec: 0.122424 seconds  Size: 2097152   Res: 3.141108
Exec: 0.987904 seconds  Size: 16777216  Res: 3.142290
Exec: 13.564010 seconds Size: 134217728 Res: 3.141560
```
