
### Usage

run `dune build` to generate the binary in the build directory. then use the
`NDOMS` environment variable to vary the _domains_ used.


### Sample results

```
Single Thread Functional

Exec: 0.000043 seconds  Size: 64        Res: 3.437500
Exec: 0.000198 seconds  Size: 512       Res: 2.992188
Exec: 0.000801 seconds  Size: 4096      Res: 3.129883
Exec: 0.007079 seconds  Size: 32768     Res: 3.133301
Exec: 0.040192 seconds  Size: 262144    Res: 3.139206
Exec: 0.170319 seconds  Size: 2097152   Res: 3.142467
Exec: 1.359598 seconds  Size: 16777216  Res: 3.141593
Exec: 17.630176 seconds Size: 134217728 Res: 3.141455

Single Thread Iterative

Exec: 0.000016 seconds  Size: 64        Res: 3.187500
Exec: 0.000026 seconds  Size: 512       Res: 3.132812
Exec: 0.000212 seconds  Size: 4096      Res: 3.128906
Exec: 0.001707 seconds  Size: 32768     Res: 3.150879
Exec: 0.013633 seconds  Size: 262144    Res: 3.148148
Exec: 0.106973 seconds  Size: 2097152   Res: 3.141115
Exec: 0.826038 seconds  Size: 16777216  Res: 3.142290
Exec: 6.557169 seconds  Size: 134217728 Res: 3.141560

Multi Thread FOR_REDUCE

Exec: 0.000684 seconds  Size: 64        Res: 3.000000
Exec: 0.000047 seconds  Size: 512       Res: 3.250000
Exec: 0.000069 seconds  Size: 4096      Res: 3.121094
Exec: 0.001759 seconds  Size: 32768     Res: 3.137207
Exec: 0.004923 seconds  Size: 262144    Res: 3.137085
Exec: 0.104235 seconds  Size: 2097152   Res: 3.141844
Exec: 0.605019 seconds  Size: 16777216  Res: 3.141498
Exec: 5.677464 seconds  Size: 134217728 Res: 3.141479

Multi Thread DIVIDE_AND_CONQUER

Exec: 0.002224 seconds  Size: 64        Res: 3.187500
Exec: 0.001417 seconds  Size: 512       Res: 3.171875
Exec: 0.001359 seconds  Size: 4096      Res: 3.164062
Exec: 0.001528 seconds  Size: 32768     Res: 3.140625
Exec: 0.005925 seconds  Size: 262144    Res: 3.142654
Exec: 0.051671 seconds  Size: 2097152   Res: 3.142803
Exec: 0.285570 seconds  Size: 16777216  Res: 3.141083
Exec: 2.245632 seconds  Size: 134217728 Res: 3.141309
```
